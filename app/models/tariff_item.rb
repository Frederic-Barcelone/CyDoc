class TariffItem < ActiveRecord::Base
  has_and_belongs_to_many :tariff_item_groups, :class_name => 'TariffItemGroup'

  def to_s
    [code, remark].compact.select{|item| not item.empty?}.join ' - '
  end

  def service_record_class
    ServiceRecord
  end

  def create_service_record(patient, provider, date, responsible = nil)
    # Type information
    service_record = service_record_class.new
    service_record.tariff_type = tariff_type

    # Tariff data
    service_record.code = code

    service_record.amount_mt = amount_mt
    service_record.unit_mt = unit_mt
    service_record.unit_factor_mt = unit_factor_mt

    service_record.amount_tt = amount_tt
    service_record.unit_tt = unit_tt
    service_record.unit_factor_tt = unit_factor_tt

    service_record.remark = remark

    # Defaults
    responsible ||= provider

    service_record.quantity = 1
    service_record.date = date

    service_record.patient = patient
    service_record.provider = provider
    service_record.responsible = responsible
    
    return service_record
  end

  # "Constant" fields
  def unit_mt
    1.89
  end

  def unit_tt
    1.89
  end

  def unit_factor_mt
    1.0
  end

  def unit_factor_tt
    1.0
  end

  # Fallbacks
  def amount_mt
    read_attribute(:amount_mt) || 0
  end

  def amount_tt
    read_attribute(:amount_tt) || 0
  end

  def tariff_type
    read_attribute(:tariff_type) || self.class.tariff_type
  end
  
  # Calculated field
  def amount
    (self.amount_mt * self.unit_factor_mt * self.unit_mt) + (self.amount_tt * self.unit_factor_tt * self.unit_tt)
  end
end
