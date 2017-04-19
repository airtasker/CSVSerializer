require "csv_serializer/version"
require 'active_support/all'

module CsvSerializer
  class CsvSerializer
    cattr_accessor :step_size
    attr_reader :attributes, :relations
    self.step_size = 1000 #default step size, for reading from the database


    #Calculated attributes are derived based on rules inside the derived class, the field is added
    def self.calc_attributes(*columns)
      attributes( Array.wrap(columns).map { |c| "NULL as #{c}" } )
    end

    #Private attributes are requested from the database, but are not added to the CSV.
    #the are here to support the query construction
    def self.private_attributes(*columns)  #these are used in the serializer, but never returned in the resulting data.
      attributes(*columns)
      @private_attributes ||= []
      if columns
        columns = Array.wrap(columns).map{ |c|  c.to_s.gsub(/^.*((as )|\.)/, '') }
        @private_attributes += columns
      end
      @private_attributes
    end

    def self.attributes(*columns)
      @attributes ||= []
      @attributes += Array.wrap(columns) if columns
      @attributes
    end

    def initialize(*relations)
      @relations = relations.map { |q| q.select(self.class.attributes) }
    end

    def scope(current_user:)
      @current_user = current_user
      self
    end

    def to_streamed_csv
      before_load
      Enumerator.new do |enumerator|
        if attributes.present?
          enumerator << header_to_enumerator.to_s
          @relations.each do |query|
            add_to_enumerator(enumerator, query)
          end
        end
      end
    end

    def to_sql
      relations.first && relations.first.to_sql
    end

  private

    attr_reader :overrides, :object, :reject_tests, :current_user

    def before_load
      @relations.each do |query|
                      first_found_record = get_raw_records(query, 1, 0).first
                      if first_found_record
                        @attributes = first_found_record.keys
                        break
                      end
                    end
      @overrides = (@attributes || [] ).reject {|x| !respond_to?(x) }
    end

    def get_raw_records(query, limit, offset)
      ActiveRecord::Base.connection.execute( query.limit(limit).offset(offset).to_sql )
    end

    def header_to_enumerator
      columns = attributes - self.class.private_attributes
      columns = columns.map{ |c| c.gsub(/[\W_]/, ' ').titlecase }
      CSV::Row.new(columns, columns, true)
    end

    def remove_not_included_values(rec)
      rec.keys.each { |key|
        if rec[key].present? && respond_to?( "include_#{key}?") && !send("include_#{key}?")
          rec[key] = nil
        end
      }
    end

    def record_to_enumerator(rec)
      rec = rec.except(*self.class.private_attributes)
      remove_not_included_values(rec)
      CSV::Row.new(rec.keys, rec.values, false)
    end

    def add_to_enumerator(enumerator, query)
      offset = 0
      records = get_raw_records(query, step_size, offset)
      while records.count > 0
        records.each do |rec|
          @object = {}.merge(rec) #create a copy of the record in object as an imutable thing
          @object.freeze
          overrides.each { |override| rec[override] = send(override) }
          enumerator << record_to_enumerator(rec).to_s
        end
        offset += step_size
        records = get_raw_records(query,step_size,  offset)
      end
    end
  end

end
