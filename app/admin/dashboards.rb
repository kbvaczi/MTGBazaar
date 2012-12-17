ActiveAdmin.register_page "Dashboard" do

  menu :priority => 1, :label => proc{ I18n.t("active_admin.dashboard") }

  content :title => proc{ I18n.t("active_admin.dashboard") } do
    
    columns do
      column do
        panel "Users Data" do
          user_info_panel
        end
        panel "Listings" do
          listings_info_panel
        end
        panel "Sales Data" do
          transactions_info_panel
        end
        panel "Stamps Data" do
          stamps_info_panel
        end
        panel "Total Income" do
          total_income_panel
        end
      end
      column do
        panel "NewRelic Data" do
          div :style => "text-align:center;" do
            text_node %{<iframe src="https://heroku.newrelic.com/public/charts/7dwwC7h2smI" width="500" height="300" scrolling="no" frameborder="no"></iframe>}.html_safe
            text_node %{<iframe src="https://heroku.newrelic.com/public/charts/4LxW774491Z" width="500" height="300" scrolling="no" frameborder="no"></iframe>}.html_safe          
          end
        end
      end
    end

    # Here is an example of a simple dashboard with columns and panels.
    #
    # columns do
    #   column do
    #     panel "Recent Posts" do
    #       ul do
    #         Post.recent(5).map do |post|
    #           li link_to(post.title, admin_post_path(post))
    #         end
    #       end
    #     end
    #   end

    #   column do
    #     panel "Info" do
    #       para "Welcome to ActiveAdmin."
    #     end
    #   end
    # end
  end # content
end

def listings_info_panel
  info = %{ <table>
              <tr>
                <th>Cards Listed:</th>
                <th style="text-align:right">#{Mtg::Cards::Listing.available.sum("quantity * number_cards_per_item").to_i}</th>
                <td>&nbsp;</td>                
                <th>Total Value:</th>
                <th style="text-align:right">#{number_to_currency(Mtg::Cards::Listing.available.sum("quantity * price")/100)}</th>
              </tr>
            </table>}
  text_node info.html_safe
end

def stamps_info_panel
  stamps_account_info ||= Rails.cache.fetch "stamps_account_info", :expires_in => 1.hours do
    Stamps.account
  end
  stamps_this_month = Mtg::Transactions::ShippingLabel.where("created_at > ?",Time.now.beginning_of_month).pluck(:price)
  shipping_paid_this_month = Mtg::Transaction.joins(:shipping_label).where("mtg_transactions_shipping_labels.created_at > ?",Time.now.beginning_of_month).pluck(:shipping_cost).sum
  info = %{ <table>
              <tr>
                <th>Available Postage:</th>
                <th style="text-align:right">#{number_to_currency(stamps_account_info[:postage_balance][:available_postage].to_f)}</th>
                <td>&nbsp;</td>                
                <th>Max Postage Balance:</th>
                <th style="text-align:right">#{number_to_currency(stamps_account_info[:max_postage_balance].to_f)}</th>
              </tr>
              <tr>
                <th>Stamps This Month:</th>
                <th style="text-align:right">#{stamps_this_month.count}</th>
                <td>&nbsp;</td>                
                <th>Postage This Month:</th>
                <th style="text-align:right">#{number_to_currency Money.new(stamps_this_month.sum)}</th>
              </tr>
              <tr>
                <th colspan=4>Money Made On Postage This Month:</th>
                <th colspan=1 style="text-align:right">#{ number_to_currency Money.new(shipping_paid_this_month - stamps_this_month.sum) }</th>
              </tr>              
            </table>}
  text_node info.html_safe
end

def transactions_info_panel
  info = Rails.cache.fetch "transaction_info_panel", :expires_in => 5.minutes do
    %{<div >
        <table>
          <tr>
            <th>Today:</th>
            <th style="text-align:right">#{Mtg::Transaction.paid.where("created_at > ?", Time.now.midnight).count}</th>
            <td>&nbsp;</td>                
            <th>Value:</th>
            <th style="text-align:right">#{number_to_currency Money.new(Mtg::Transaction.paid.where("created_at > ?", Time.now.midnight).pluck(:value).sum)}</th>
            <td>&nbsp;</td>                          
            <th>Commission:</th>
            <th style="text-align:right">#{number_to_currency Money.new( Mtg::Transactions::Payment.where("created_at > ?", Time.now.midnight).pluck(:commission).sum)}</th>
          </tr>
          <tr>
            <th>This Month:</th>
            <th style="text-align:right">#{Mtg::Transaction.paid.where("created_at > ?", Time.now.beginning_of_month).count}</th>
            <td>&nbsp;</td>                
            <th>Value:</th>
            <th style="text-align:right">#{number_to_currency Money.new(Mtg::Transaction.paid.where("created_at > ?", Time.now.beginning_of_month).pluck(:value).sum)}</th>
            <td>&nbsp;</td>                          
            <th>Commission:</th>
            <th style="text-align:right">#{number_to_currency Money.new( Mtg::Transactions::Payment.where("created_at > ?", Time.now.beginning_of_month).pluck(:commission).sum)}</th>
          </tr>
          <tr>
            <th>This Year:</th>
            <th style="text-align:right">#{Mtg::Transaction.paid.where("created_at > ?", Time.now.beginning_of_year).count}</th>
            <td>&nbsp;</td>                
            <th>Value:</th>
            <th style="text-align:right">#{number_to_currency Money.new(Mtg::Transaction.paid.where("created_at > ?", Time.now.beginning_of_year).pluck(:value).sum)}</th>
            <td>&nbsp;</td>                          
            <th>Commission:</th>
            <th style="text-align:right">#{number_to_currency Money.new( Mtg::Transactions::Payment.where("created_at > ?", Time.now.beginning_of_year).pluck(:commission).sum)}</th>
          </tr>
        </table>
      </div>}
  end
  text_node info.html_safe
end

def user_info_panel
  info = Rails.cache.fetch("user_info_panel", :expires_in => 5.minutes) do
    %{<table>
        <tr>
          <th>New Accounts Today:</th>
          <th style="text-align:right">#{User.where("created_at > ?", Time.now.midnight).count}</th>
          <td>&nbsp;</td>                
          <th>Total Accounts:</th>
          <th style="text-align:right">#{User.count}</th>
        </tr>
        <tr>
          <th>Users Online Now:</th>
          <th style="text-align:right">#{Session.where("updated_at > ?", 10.minutes.ago).count}</th>
          <td>&nbsp;</td>
          <th>Users Logged In Today:</th>
          <th style="text-align:right">#{User.where("users.current_sign_in_at > ?", Time.now.midnight).count}</th>
        </tr>

      </table>}
  end
  text_node info.html_safe
end

def total_income_panel
  Rails.cache.fetch "total_income_panel", :expires_in => 5.minutes do
    # Today
    commission_today      = Money.new(Mtg::Transactions::Payment.where("created_at > ?", Time.now.midnight).pluck(:commission).sum)
    commission_this_month = Money.new(Mtg::Transactions::Payment.where("created_at > ?", Time.now.beginning_of_month).pluck(:commission).sum)
    commission_this_year  = Money.new( Mtg::Transactions::Payment.where("created_at > ?", Time.now.beginning_of_year).pluck(:commission).sum)
  
    earned_on_stamps_today        = Money.new(Mtg::Transaction.joins(:shipping_label).where("mtg_transactions_shipping_labels.created_at > ?",Time.now.midnight).pluck(:shipping_cost).sum - Mtg::Transactions::ShippingLabel.where("created_at > ?",Time.now.midnight).pluck(:price).sum)
    earned_on_stamps_this_month   = Money.new(Mtg::Transaction.joins(:shipping_label).where("mtg_transactions_shipping_labels.created_at > ?",Time.now.beginning_of_month).pluck(:shipping_cost).sum - Mtg::Transactions::ShippingLabel.where("created_at > ?",Time.now.beginning_of_month).pluck(:price).sum)
    earned_on_stamps_this_year    = Money.new(Mtg::Transaction.joins(:shipping_label).where("mtg_transactions_shipping_labels.created_at > ?",Time.now.beginning_of_year).pluck(:shipping_cost).sum - Mtg::Transactions::ShippingLabel.where("created_at > ?",Time.now.beginning_of_year).pluck(:price).sum)
    
    info = %{ <table>
                <tr>
                  <th>Today:</th>
                  <th style="text-align:right">#{number_to_currency(commission_today + earned_on_stamps_today)}</th>
                  <td>&nbsp;</td>                
                  <th>This Month:</th>
                  <th style="text-align:right">#{number_to_currency(commission_this_month + earned_on_stamps_this_month)}</th>
                  <td>&nbsp;</td>                                                    
                  <th>This Year:</th>
                  <th style="text-align:right">#{number_to_currency(commission_this_year + earned_on_stamps_this_year)}</th>
                </tr>
              </table>}
  end.html_safe
end
=begin
ActiveAdmin::Dashboards.build do

  # Define your dashboard sections here. Each block will be
  # rendered on the dashboard in the context of the view. So just
  # return the content which you would like to display.
  
  section "Connection Statistics", :priority => 3 do
    div do
      br
      text_node %{<iframe src="https://heroku.newrelic.com/public/charts/7dwwC7h2smI" width="500" height="300" scrolling="no" frameborder="no"></iframe>}.html_safe
      text_node %{  <iframe src="https://heroku.newrelic.com/public/charts/4LxW774491Z" width="500" height="300" scrolling="no" frameborder="no"></iframe>}.html_safe
    end
  
  end
  
  # == Simple Dashboard Section
  # Here is an example of a simple dashboard section
  #
  #   section "Recent Posts" do
  #     ul do
  #       Post.recent(5).collect do |post|
  #         li link_to(post.title, admin_post_path(post))
  #       end
  #     end
  #   end
  
  # == Render Partial Section
  # The block is rendered within the context of the view, so you can
  # easily render a partial rather than build content in ruby.
  #
  #   section "Recent Posts" do
  #     div do
  #       render 'recent_posts' # => this will render /app/views/admin/dashboard/_recent_posts.html.erb
  #     end
  #   end
  
  # == Section Ordering
  # The dashboard sections are ordered by a given priority from top left to
  # bottom right. The default priority is 10. By giving a section numerically lower
  # priority it will be sorted higher. For example:
  #
  #   section "Recent Posts", :priority => 10
  #   section "Recent User", :priority => 1
  #
  # Will render the "Recent Users" then the "Recent Posts" sections on the dashboard.
  
  # == Conditionally Display
  # Provide a method name or Proc object to conditionally render a section at run time.
  #
  # section "Membership Summary", :if => :memberships_enabled?
  # section "Membership Summary", :if => Proc.new { current_admin_user.account.memberships.any? }
  

end
=end