require 'mongoid'
require 'namey'
require 'autoinc'
require 'faker'
require 'mongo'

Mongoid.load!("./mongoid.yml", :development)

module RandomGenerators

  def random_int(max)
    ((rand * max * 1000 ) % max).to_i
  end

  def random_id(x = 50)
    o = [('a'..'z'), ('A'..'Z')].map(&:to_a).flatten
    (0...x).map { o[rand(o.length)] }.join
  end

  def random_numeric_id(x = 50)
    o = [('0'..'9')].map(&:to_a).flatten
    (0...x).map { o[rand(o.length)] }.join
  end

  def gender
    ((rand * 10 ) % 2).to_i == 0 ? 'f' : 'm'
  end

  def name_generator
    if @name_generator.nil?
      @name_generator = Namey::Generator.new
    end
    @name_generator
  end

  def random_name(gender)
    gender == 'f' ? name_generator.female : name_generator.male
  end

  def time_rand age
    from = Time.now - (60 * 60 * 24 * 365 * age)
    to = Time.now - (60 * 60 * 24 * 365 * (age - 10))
    Time.at(from + rand * (to.to_f - from.to_f))
  end

  def age
    v = ((rand * 100 ) % 100).to_i
    v < 18 ? 18 : v
  end

  def one_of xs
    xs[((rand * 10) % xs.count).to_i]
  end

  def random_email(name)
    email = Faker::Internet.email
    domain = email.split("@").last
    "#{name}@#{domain}"
  end
end

class CustomerData
  include Mongoid::Document
  include Mongoid::Autoinc
  extend RandomGenerators


  field :customer_id, type: Integer
  field :type, type: String
  field :lei, type: String
  field :email, type: String
  field :tax_id, type: String
  field :title, type: String
  field :given_name, type: String
  field :family_name, type: String
  field :gender, type: String
  field :vat_id, type: String
  field :birth_date, type: String
  field :death_date, type: String

  increments :customer_id

  def self.next
    customer_gender = gender
    titles = customer_gender == 'm' ? ['mr', 'dr'] : ['ms', 'mrs', 'dr']
    given, family = random_name(customer_gender).split(/\s+/)
    customer_age = age
    email = random_email("#{given}.#{family}")

    CustomerData.new(type: one_of(["personal", "finance"]),
                     lei: random_id(10),
                     tax_id: random_id(10),
                     title: one_of(titles),
                     gender: customer_gender,
                     email: email,
                     given_name: given,
                     family_name: family,
                     vat_id: random_id(10),
                     birth_date: time_rand(customer_age))
  end

end


class BankAccountData
  include Mongoid::Document
  include Mongoid::Autoinc
  extend RandomGenerators

  field :account_id, type: Integer
  field :customer_id, type: Integer
  field :account_number, type: String
  field :account_type, type: String
  field :amount, type: Integer
  field :lei, type: String
  field :fees_and_comissions, type: String
  field :review_state, type: String
  field :interest_rate, type: Integer
  field :annual_interest_rate, type: Integer
  field :minimum_overflow, type: Integer
  field :overdraft_limit, type: Integer

  increments :account_id

  def self.next(customer_id)
    BankAccountData.new(customer_id: customer_id,
                        account_number: random_numeric_id(16),
                        account_type: one_of(['checking', 'savings']),
                        amount: random_int(1_000_000),
                        lei: random_id(10),
                        fees_and_comissions: one_of(["Standard fees and comissions", "Special fees and comissions"]),
                        review_state: one_of(['approved', 'pending']),
                        interest_rate: random_int(3),
                        annual_interest_rate: random_int(10),
                        minimum_overflow: random_int(3) * 100,
                        overdraft_limit: random_int(5) * 1000)
  end
end

class AddressData
  include Mongoid::Document
  include Mongoid::Autoinc
  extend RandomGenerators

  field :address_id, type: Integer
  field :customer_id, type: Integer
  field :country, type: String
  field :locality, type: String
  field :postal_code, type: String
  field :address, type: String

  increments :address_id

  def self.next(customer_id)
    AddressData.new(customer_id: customer_id,
                    country: Faker::Address.country,
                    locality: Faker::Address.city,
                    postal_code: Faker::Address.postcode,
                    address: Faker::Address.street_address)
  end

end


include RandomGenerators

def generate(num_users)
  CustomerData.destroy_all
  BankAccountData.destroy_all
  AddressData.destroy_all
  (0 .. num_users).each do |i|
    c = CustomerData.next
    c.save!
    (0 .. random_int(10)).each do |j|
      BankAccountData.next(c.customer_id).save!
    end
    AddressData.next(c.customer_id).save!
  end
end
