namespace :fake_basics do

  desc "TODO: Generate fake basic datas"
  task all: [
              :create_products,
              :create_shops,
              :create_gift_cards,
              :create_categories,
              :create_machines,
              :create_shippings,
              :create_credit_cards,
              :create_cust_accounts
            ]

  desc "TODO: Generate fake products."
  task create_products: :environment do
    puts "TODO: Generate fake products."
    100.times do
      Product.create(user_id: 1, region_id: 1, title: Faker::Commerce.product_name, url: "https://www.amazon.com/dp/#{Faker::Code.asin}")
    end
  end
  
  desc "TODO: Generate fake shops."
  task create_shops: :environment do
    puts "TODO: Generate fake shops."
    50.times do
      seller_id = SecureRandom.alphanumeric.upcase[0..13]
      Shop.create(user_id: 1, region_id: 1, name: Faker::App.name, remark: Faker::App.name, url: "https://www.amazon.com/sp?_encoding=UTF8&isAmazonFulfilled=0&isCBA=&marketplaceID=ATVPDKIKX0DER&orderID=&seller=A#{seller_id}&tab=&vasStoreID=")
    end
  end
  
  desc "TODO: Generate fake categories."
  task create_categories: :environment do
    puts "TODO: Generate fake categories."
    50.times do
      name = Faker::Commerce.department
      Category.create(user_id: 1, region_id: 1, name: name, search_alias: name.split(/[,|&]/)[0].downcase)
    end
  end
 
  desc "TODO: Generate fake gift cards."
  task create_gift_cards: :environment do
    puts "TODO: Generate fake gift cards."
    100.times do
      claim_code = SecureRandom.alphanumeric.insert(4, '-').insert(11, '-').upcase[0..15]
      GiftCard.create(user_id: 1, region_id: 1, claim_code: claim_code, face_value: rand(50))
    end
  end

  desc "TODO: Generate fake machines."
  task create_machines: :environment do
    puts "TODO: Generate fake machines."
    30.times do |i|
      @machine = Machine.create(user_id: 1, region_id: 1, role: [1, 2, 3].sample, name: "vcamazon#{i+1}", supplier: '华普', host: Faker::Internet.ip_v4_address, started_at: Time.now, expired_at: Time.now + 1.month)
      20.times do
        if @machine.valid?
          @machine.proxies.create(ip: Faker::Internet.ip_v4_address)
        end
      end
    end
  end

  desc "TODO: Generate fake shippings."
  task create_shippings: :environment do
    puts "TODO: Generate fake shippings."
    100.times do
      Shipping.create(user_id: 1, region_id: 1, role: 0, first_name: Faker::Name.first_name, last_name: Faker::Name.last_name, address1: Faker::Address.street_address, address2: Faker::Address.secondary_address, city: @city = Faker::Address.city_prefix, state: @state = Faker::Address.state, zip: @zip = Faker::Address.zip, city_state_zip: "#{@city} #{@state}, #{@zip}", phone: Faker::PhoneNumber.cell_phone, country: "United States", ssn: rand(100000000..999999999), birth: Time.now.to_date, remark: 'fake')
    end
  end

  desc "TODO: Generate fake credit_cards."
  task create_credit_cards: :environment do
    puts "TODO: Generate fake credit_cards."
    100.times do
      bank  = brand = [
                        :visa,
                        :mastercard,
                        :amex,
                        :diners,
                        :jcb,
                        :solo,
                        :switch,
                        :maestro,
                        :unionpay,
                        :dankort,
                        :rupay,
                        :hipercard,
                        :elo,
                        :mir,
                        :discover
                      ].sample
      @card = CreditCard.create(user_id: 1, region_id: 1, bank: bank, brand: brand.to_s, number: @number = CreditCardValidations::Factory.random(brand), cvv: Faker::CreditCard.cvv, ending: @number.last(4), exp_month: Faker::CreditCard.expire_date(:month), exp_year: Faker::CreditCard.expire_date(:year), routing: rand(100000000..999999999), bought_by: "wenwen", limit: rand(50..500), remark: 'fake')
      @card.card_billings.create(shipping_id: rand(1..50)) if @card.valid?
    end
  end

  desc "TODO: Generate fake cust_accounts."
  task create_cust_accounts: :environment do
    puts "TODO: Generate fake cust_accounts."
    5.times do
      role = ['zp', 'vp'].sample
      @batch = CustAccountBatch.create(user_id: 1, region_id: 1, role: role, name: "US-cust_accounts-20180606-1k-3L-#{role}", supplier: 'XiaoWaiBa', remark: 'fake')
      100.times do
        if @batch.valid?
          @batch.cust_accounts.create(region_id: 1, current_email: @email = Faker::Internet.free_email, origin_email: @email, current_passwd: @passwd = Faker::Internet.password, origin_passwd: @passwd, role: role, name: Faker::Name.name, desktop_ua: @ua = Faker::Internet.user_agent, mobile_ua: @ua, remark: 'fake')
        end
      end
    end
  end

end
