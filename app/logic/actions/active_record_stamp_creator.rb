class ActiveRecordStampCreator

  def initialize(options)
    @records = options[:records]
    @new_attributes = options[:new_attributes]
  end

  def perform(&block)
    records.each do |record|
      new_record = record.dup
      new_record.assign_attributes(new_attributes)
      block.call(new_record, record)
    end
  end

  private

  attr_reader :records, :new_attributes

end
