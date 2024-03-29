require 'rails_helper'

RSpec.describe RealtorContact do

  it 'doesn\'t save new contact if choice has value not included in the list' do
    contact = RealtorContact.new(choice: 'email_and_phone_submitted_but_contact_wont_save',
                                 email: 'test@example.com',
                                 phone: '1234567890')
    expect(contact.invalid?).to be_truthy
  end

  it 'responds to call_me? once corresponding choice set' do
    contact = RealtorContact.new(choice: 'call_me', phone: '123')
    expect(contact.call_me?).to be_truthy
  end

  it 'responds to call_me? once corresponding choice set' do
    contact = RealtorContact.new(choice: 'email_me', email: '123')
    expect(contact.email_me?).to be_truthy
  end

  context 'realtor provided email' do
    it 'doesn\'t save new contact if email is absent' do
      contact = RealtorContact.new(choice: 'email_me')
      expect(contact.invalid?).to be_truthy
    end

    it 'doesn\'t save new contact if email is empty string' do
      contact = RealtorContact.new(choice: 'email_me', email: '')
      expect(contact.invalid?).to be_truthy
    end

    it 'doesn\'t save new contact if email is not unique' do
      RealtorContact.create!(choice: 'email_me', email: 'test@example.com')
      contact = RealtorContact.new(choice: 'email_me', email: 'test@example.com')
      expect(contact.invalid?).to be_truthy
    end

    it 'doesn\'t save new contact if email doesn\'t contain @ symbol' do
      contact = RealtorContact.new(choice: 'email_me', email: 'test')
      expect(contact.invalid?).to be_truthy
    end

    it 'doesn\'t save new contact if email doesn\'t contain domain name' do
      contact = RealtorContact.new(choice: 'email_me', email: 'test@example')
      expect(contact.invalid?).to be_truthy
    end

    it 'doesn\'t save new contact if email doesn\'t contain valid domain' do
      contact = RealtorContact.new(choice: 'email_me', email: 'test@example.c')
      expect(contact.invalid?).to be_truthy
    end

    it 'saves new contact' do
      contact = RealtorContact.new(choice: 'email_me', email: 'test@example.com')
      expect(contact.valid?).to be_truthy
    end
  end

  context 'realtor provided phone' do
    it 'doesn\'t save new contact if phone is absent' do
      contact = RealtorContact.new(choice: 'call_me')
      expect(contact.invalid?).to be_truthy
    end

    it 'doesn\'t save new contact if phone is empty' do
      contact = RealtorContact.new(choice: 'call_me', phone: '')
      expect(contact.invalid?).to be_truthy
    end

    it 'doesn\'t save new contact if phone is not numerical' do
      contact = RealtorContact.new(choice: 'call_me', phone: 'abcdefghij')
      expect(contact.invalid?).to be_truthy
    end

    it 'doesn\'t save new contact if phone is not numerical' do
      contact = RealtorContact.new(choice: 'call_me', phone: 'abcdefghij')
      expect(contact.invalid?).to be_truthy
    end

    it 'doesn\'t save new contact if phone contains less than 10 digits' do
      contact = RealtorContact.new(choice: 'call_me', phone: '123')
      expect(contact.invalid?).to be_truthy
    end

    it 'doesn\'t save new contact if phone contains too many digits' do
      contact = RealtorContact.new(choice: 'call_me', phone: '12345678901234567890')
      expect(contact.invalid?).to be_truthy
    end

    it 'doesn\'t save new contact if phone number is not unique' do
      RealtorContact.create!(choice: 'call_me', phone: '1234567890')
      contact = RealtorContact.new(choice: 'call_me', email: '1234567890')
      expect(contact.invalid?).to be_truthy
    end

    it 'saves new contact' do
      contact = RealtorContact.new(choice: 'call_me', phone: '1234567890')
      expect(contact.valid?).to be_truthy
    end
  end

end