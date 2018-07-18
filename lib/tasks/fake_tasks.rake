namespace :fake_tasks do

  # 跳过回调
  # http://thelazylog.com/skip-activerecord-callbacks/

  desc "TODO: Generate fake tasks"
  task all: [
              :create_purchase_tasks,
              :create_review_write_tasks,
              :create_ranking_tasks,
              :create_ranking_check_tasks,
              :create_review_crawl_tasks,
              :create_review_vote_tasks,
              :create_question_vote_tasks,
              :create_question_ask_tasks,
              :create_question_answer_tasks,
              :create_prod_crawl_tasks,
              :create_sp_related_tasks,
              :create_email_attack_tasks
            ]


  desc "TODO Generate fake purchase_tasks"
  task create_purchase_tasks: :environment do
    puts "TODO Generate fake purchase_tasks"
    PurchaseTask.skip_callback(:execute_task)
    50.times do
      order_code = "113-"+"#{Random.new_seed}"[0..13].insert(7, '-')
      @task = PurchaseTask.create(user_id: 1, region_id: 1, device: rand(2), priority: rand(2), account_role: rand(2), shipping: rand(2), payment: rand(2), subtotal: rand(50), cart_delay: rand(1..10)*10, cart_retry_times: cart_retry_times = rand(1..3), order_delay: rand(1..10)*10, order_retry_times: order_retry_times = rand(1..3), status: 2, remark: 'fake')
      if @task.valid?
        rand(1..7).times do |time|
          @task.purchase_prods.create(shop_id: rand(1..50), search_mode_id: rand(2..5), product_id: rand(1..30), category_id: rand(1..30), keyword: Faker::Commerce.product_name, price: rand(34..67), ranking: rand(20), showed_page: rand(20), max_page: 200, a_href: "https://www.amazon.com/dp/#{Faker::Code.asin}", prod_role: rand(2), order_code: order_code, exec_review: false, remark: 'fake')
        end
        # purchase_cart_log detail
        cart_retry_times.times do |time|
          cart_log = @task.purchase_cart_logs.create(proxy_id: rand(1..300), user_agent: Faker::Internet.user_agent, spent_time: rand(20..80), times: time + 1, status: 2, carted_at: Time.now - rand(1..10).days)
          # purchase_order_log detail
          order_retry_times.times do |time|
            cart_log.purchase_order_logs.create(order_total: rand(34.0..56.0), spent_time: rand(20..80), times: time + 1, order_code: order_code, ordered_at: Time.now - rand(1..10).days, shipped_at: Time.now - rand(1..10).days, status: 2)
          end
        end
      end
    end
  end

  desc "TODO Generate fake review_write_tasks"
  task create_review_write_tasks: :environment do
    puts "TODO Generate fake review_write_tasks"
    ReviewWriteTask.skip_callback(:execute_task)
    50.times do |time|
      retry_times = rand(1..3)
      review_id = "R#{SecureRandom.alphanumeric.upcase[0..13]}"
      @task = ReviewWriteTask.create(user_id: 1, region_id: 1, search_mode_id: rand(2..5), purchase_prod_id: time + 1, category_id: rand(1..30), device: rand(2), priority: rand(2), keyword: Faker::Commerce.product_name, max_page: 200, star: rand(4..5), title: Faker::Book.title, content: Faker::Lebowski.quote, retry_times: retry_times, delay: rand(1..10)*10, status: 2, remark: 'fake')
      if @task.valid?
        retry_times.times do |time|
          @task.review_write_logs.create(cust_account_id: rand(1..300), proxy_id: rand(1..300), user_agent: Faker::Internet.user_agent, spent_time: rand(20..80), ranking: rand(20), showed_page: rand(20), max_page: 200, a_href: "https://www.amazon.com/dp/#{Faker::Code.asin}", prod_role: rand(2), times: time+1, review_id: review_id, reviewed_at: Time.now - rand(1..10).days, status: 2)
        end
      end
    end
  end

  desc "TODO Generate fake ranking_tasks"
  task create_ranking_tasks: :environment do
    puts "TODO Generate fake ranking_tasks"
    RankingTask.skip_callback(:execute_task)
    50.times do
      @task = RankingTask.create(user_id: 1, search_mode_id: rand(2..5), product_id: rand(1..30), category_id: rand(1..30), device: rand(2), priority: rand(2), keyword: Faker::Commerce.product_name, max_page: 200, operate_times: (times = rand(1..20)*10), success_times: times/2, delay: rand(1..10)*10, status: 2, remark: 'fake')
      if @task.valid?
        20.times do |time|
          @task.ranking_logs.create(cust_account_id: rand(1..300), proxy_id: rand(1..300), user_agent: Faker::Internet.user_agent, spent_time: rand(20..80), ranking: rand(20), showed_page: rand(20), max_page: 200, a_href: "https://www.amazon.com/dp/#{Faker::Code.asin}", prod_role: rand(2), times: time+1, status: 2, is_cart: 1, is_wish: 1, is_review: 1, is_image: 1)
        end
      end
    end
  end

  desc "TODO Generate fake ranking_check_tasks"
  task create_ranking_check_tasks: :environment do
    puts "TODO Generate fake ranking_check_tasks"
    RankingCheckTask.skip_callback(:execute_task)
    50.times do
      @task = RankingCheckTask.create(user_id: 1, product_id: rand(1..30), category_id: rand(1..30), device: rand(2), priority: rand(2), prod_role: rand(2), keyword: Faker::Commerce.product_name, max_page: 200, operate_times: (operate_times = rand(1..3)), success_times: operate_times, delay: rand(0..10)*10, status: 2, remark: 'fake')
      if @task.valid?
        operate_times.times do |time|
          @task.ranking_check_logs.create(proxy_id: rand(1..300), user_agent: Faker::Internet.user_agent, spent_time: rand(20..80), ranking: rand(20), showed_page: rand(20), max_page: 200, a_href: "https://www.amazon.com/dp/#{Faker::Code.asin}", prod_role: rand(2), times: time+1, status: 2)
        end
      end
    end
  end

  desc "TODO Generate fake review_crawl_tasks"
  task create_review_crawl_tasks: :environment do
    puts "TODO Generate fake review_crawl_tasks"
    ReviewCrawlTask.skip_callback(:execute_task)
    50.times do
      asin  = Faker::Code.asin
      title = Faker::Commerce.product_name.parameterize
      @task = ReviewCrawlTask.create(user_id: 1, region_id: 1, proxy_id: rand(1..300), device: rand(2), priority: rand(2), url: "https://www.amazon.com/#{title}/product-reviews/#{asin}/ref=cm_cr_arp_d_viewopt_sr?ie=UTF8&reviewerType=all_reviews&filterByStar=five_star&pageNumber=1", title: title, asin: asin, delay: rand(0..10)*10, status: 2, remark: 'faker')
      if @task.valid?
        rand(30..50).times do |time|
          @task.review_crawl_logs.create(url: "https://www.amazon.com/gp/customer-reviews/R#{SecureRandom.alphanumeric.upcase[0..13]}/ref=cm_cr_arp_d_rvw_ttl?ie=UTF8&ASIN=#{asin}&tag=ama207-20", star: rand(4..5), title: Faker::Book.title, content: Faker::Lebowski.quote, author: Faker::Name.name, author_profile: "https://www.amazon.com/gp/profile/amzn1.account.A#{SecureRandom.hex.upcase[0..27]}/ref=cm_cr_arp_d_pdp?ie=UTF8&tag=ama207-20", wrote_at: Time.now - rand(1..10).days)
        end
      end
    end
  end

  desc "TODO Generate fake review_vote_tasks"
  task create_review_vote_tasks: :environment do
    puts "TODO Generate fake review_vote_tasks"
    ReviewVoteTask.skip_callback(:execute_task)
    50.times do
      review_id = "R#{SecureRandom.alphanumeric.upcase[0..13]}"
      @task = ReviewVoteTask.create(user_id: 1, search_mode_id: rand(2..5), product_id: rand(1..50), category_id: rand(1..30), device: rand(2), priority: rand(2), url: "https://www.amazon.com/gp/customer-reviews/#{review_id}/ref=cm_cr_dp_d_rvw_ttl?ie=UTF8", vote: rand(2), keyword: Faker::Commerce.product_name, max_page: 200, operate_times: (operate_times = rand(1..5)*10), success_times: operate_times/2, delay: rand(0..10)*10, status: 2, remark: 'faker')
      if @task.valid?
        operate_times.times do |time|
          @task.review_vote_logs.create(cust_account_id: rand(1..300), proxy_id: rand(1..300), user_agent: Faker::Internet.user_agent, spent_time: rand(20..80), ranking: rand(20), showed_page: rand(20), max_page: 200, a_href: "https://www.amazon.com/dp/#{Faker::Code.asin}", prod_role: rand(2), times: time + 1, status: 2, voted_at: Time.now - rand(1..10).days)
        end
      end
    end
  end

  desc "TODO Generate fake question_vote_tasks"
  task create_question_vote_tasks: :environment do
    puts "TODO Generate fake question_vote_tasks"
    QuestionVoteTask.skip_callback(:execute_task)
    50.times do
      question_id = "Tx#{SecureRandom.alphanumeric.upcase[0..13]}"
      @task = QuestionVoteTask.create(user_id: 1, search_mode_id: rand(2..5), product_id: rand(1..50), category_id: rand(1..30), device: rand(2), priority: rand(2), url: "https://www.amazon.com/ask/questions/#{question_id}/ref=ask_ql_ql_al_hza", vote: rand(2), keyword: Faker::Commerce.product_name, max_page: 200, operate_times: (operate_times = rand(1..5)*10), success_times: operate_times/2, delay: rand(0..10)*10, status: 2, remark: 'faker')
      if @task.valid?
        operate_times.times do |time|
          @task.question_vote_logs.create(cust_account_id: rand(1..300), proxy_id: rand(1..300), user_agent: Faker::Internet.user_agent, spent_time: rand(20..80), ranking: rand(20), showed_page: rand(20), max_page: 200, a_href: "https://www.amazon.com/dp/#{Faker::Code.asin}", prod_role: rand(2), times: time + 1, status: 2, voted_at: Time.now - rand(1..10).days)
        end
      end
    end
  end

  desc "TODO Generate fake question_ask_tasks"
  task create_question_ask_tasks: :environment do
    puts "TODO Generate fake question_ask_tasks"
    QuestionAskTask.skip_callback(:execute_task)
    50.times do
      retry_times = rand(1..3)
      question_id = "Tx#{SecureRandom.alphanumeric.upcase[0..13]}"
      @task = QuestionAskTask.create(user_id: 1, search_mode_id: rand(2..5), product_id: rand(1..50), category_id: rand(1..30), device: rand(2), priority: rand(2), content: Faker::Lebowski.quote, keyword: Faker::Commerce.product_name, max_page: 200, retry_times: retry_times, delay: rand(0..10)*10, status: 2, remark: 'faker')
      if @task.valid?
        retry_times.times do |time|
          @task.question_ask_logs.create(cust_account_id: rand(1..300), proxy_id: rand(1..300), user_agent: Faker::Internet.user_agent, spent_time: rand(20..80), ranking: rand(20), showed_page: rand(20), max_page: 200, a_href: "https://www.amazon.com/dp/#{Faker::Code.asin}", prod_role: rand(2), question_id: question_id, times: time + 1, status: 2, asked_at: Time.now - rand(1..10).days)
        end
      end
    end
  end

  desc "TODO Generate fake question_answer_tasks"
  task create_question_answer_tasks: :environment do
    puts "TODO Generate fake question_answer_tasks"
    QuestionAnswerTask.skip_callback(:execute_task)
    50.times do
      retry_times = rand(1..3)
      question_id = "Tx#{SecureRandom.alphanumeric.upcase[0..13]}"
      answer_id   = "Mx#{SecureRandom.alphanumeric.upcase[0..13]}"
      @task = QuestionAnswerTask.create(user_id: 1, search_mode_id: rand(2..5), product_id: rand(1..50), category_id: rand(1..30), device: rand(2), priority: rand(2), url: "https://www.amazon.com/ask/questions/#{question_id}/ref=ask_ql_ql_al_hza", content: Faker::Lebowski.quote, keyword: Faker::Commerce.product_name, max_page: 200, retry_times: retry_times, delay: rand(0..10)*10, status: 2, remark: 'faker')
      if @task.valid?
        retry_times.times do |time|
          @task.question_answer_logs.create(cust_account_id: rand(1..300), proxy_id: rand(1..300), user_agent: Faker::Internet.user_agent, spent_time: rand(20..80), ranking: rand(20), showed_page: rand(20), max_page: 200, a_href: "https://www.amazon.com/dp/#{Faker::Code.asin}", answer_id: answer_id,prod_role: rand(2), times: time + 1, status: 2, answered_at: Time.now - rand(1..10).days)
        end
      end
    end
  end

  desc "TODO Generate fake prod_crawl_tasks"
  task create_prod_crawl_tasks: :environment do
    puts "TODO Generate fake prod_crawl_tasks"
    ProdCrawlTask.skip_callback(:execute_task)
    50.times do
      asin  = Faker::Code.asin
      @task = ProdCrawlTask.create(user_id: 1, category_id: rand(1..30), proxy_id: rand(1..300), device: rand(2), priority: rand(2), keyword: Faker::Commerce.product_name, max_page: 200, delay: rand(0..10)*10, status: 2, remark: 'faker')
      if @task.valid?
        30.times do |time|
          @task.prod_crawl_logs.create(asin: asin, img_url: Faker::Avatar.image, title: Faker::Book.title, a_href: "https://www.amazon.com/dp/#{Faker::Code.asin}", brand: Faker::Name.first_name, price: Faker::Commerce.price, star: rand(4..5), review: rand(1..300), ranking: time + 1, showed_page: rand(1..3), prod_role: rand(2), status: 2)
        end
      end
    end
  end

  desc "TODO Generate fake sp_related_tasks"
  task create_sp_related_tasks: :environment do
    puts "TODO Generate fake sp_related_tasks"
    SpRelatedTask.skip_callback(:execute_task)
    50.times do
      @task = SpRelatedTask.create(user_id: 1, search_mode_id: rand(2..5), product_id: rand(1..30), category_id: rand(1..30), device: rand(2), priority: rand(2), url: "https://www.amazon.com/dp/#{Faker::Code.asin}", keyword: Faker::Commerce.product_name, max_page: 200, operate_times: (times = rand(1..20)*10), success_times: times/2, delay: rand(1..10)*10, status: 2, remark: 'fake')
      if @task.valid?
        20.times do |time|
          @task.sp_related_logs.create(cust_account_id: rand(1..300), proxy_id: rand(1..300), user_agent: Faker::Internet.user_agent, spent_time: rand(20..80), ranking: rand(20), showed_page: rand(20), max_page: 200, a_href: "https://www.amazon.com/dp/#{Faker::Code.asin}", prod_role: rand(2), times: time+1, status: 2, is_cart: 1, is_wish: 1, is_review: 1, is_image: 1)
        end
      end
    end
  end

  desc "TODO Generate fake email_attack_tasks"
  task create_email_attack_tasks: :environment do
    puts "TODO Generate fake email_attack_tasks"
    EmailAttackTask.skip_callback(:execute_task)
    50.times do
      @task = EmailAttackTask.create(user_id: 1, shop_id: rand(1..50), device: rand(2), priority: rand(2), content: Faker::Lebowski.quote, operate_times: (times = rand(1..20)*10), success_times: times/2, delay: rand(0..10)*10, status: 2, remark: 'faker')
      if @task.valid?
        times.times do |time|
          @task.email_attack_logs.create(cust_account_id: rand(1..300), proxy_id: rand(1..300), user_agent: Faker::Internet.user_agent, spent_time: rand(20..80), times: time + 1, status: 2, sent_at: Time.now - rand(1..10).days)
        end
      end
    end
  end

end
