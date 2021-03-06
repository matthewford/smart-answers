require_relative "../../test_helper"

module SmartAnswer::Calculators
  class RegistrationsDataQueryTest < ActiveSupport::TestCase
    
    context RegistrationsDataQuery do
      setup do
        @query = SmartAnswer::Calculators::RegistrationsDataQuery.new
      end
      context "registration_data method" do
        should "read registrations data" do
          assert_equal Hash, @query.data.class
        end
      end
      context "commonwealth_country? method" do
        should "indicate whether a country slug refers to a commonwealth country" do
          assert @query.commonwealth_country?('australia')
          refute @query.commonwealth_country?('spain')         
        end
      end
      context "clickbook method" do
        should "return the url for a country with a single clickbook url" do
          assert_equal "http://www.britishembassyinbsas.clickbook.net/", @query.clickbook('argentina')
        end
        should "return a hash of urls keyed by city for countries with multiple clickbooks" do
          clickbook = @query.clickbook('china')
          assert_equal Hash, clickbook.class
          assert_equal "Beijing", clickbook.keys.first
          assert_equal "https://www.clickbook.net/dev/bc.nsf/sub/BritConChongqing", clickbook["Chongqing"]
        end
      end
      context "has_high_commission?" do
        should "be true for countries with a high commission" do
          assert @query.has_high_commission?('trinidad-and-tobago')
          refute @query.has_high_commission?('australia')
        end
      end
      context "has_consulate?" do
        should "be true for countries with a consulate" do
          assert @query.has_consulate?('russian-federation')
          refute @query.has_consulate?('uganda')
        end
      end
      context "cash_only?" do
        should "be true for countries that only accept cash" do
          assert @query.cash_only?('iceland')
          refute @query.cash_only?('spain')
        end
      end
      context "register_death_by_post?" do
        should "be true for countries that allow registration by post" do
          assert @query.register_death_by_post?('belgium')
          refute @query.register_death_by_post?('afghanistan')
        end
      end
      context "death_postal_form" do
        should "give the form url if it exists" do
          assert_equal "http://ukinaustria.fco.gov.uk/resources/en/pdf/pdf1/credit-card-form", @query.death_postal_form('austria')
          refute @query.death_postal_form('united-states')
        end
      end
      context "death_postal_return_form" do
        should "give the form url if it exists" do
          assert_equal "http://ukinitaly.fco.gov.uk/resources/en/word/3121380/Return-delivery-form", @query.death_postal_return_form('italy')
          refute @query.death_postal_return_form('belgium')
        end
      end
      context "registration_country_slug" do
        should "map the country to a registration country if one exists" do
          assert_equal "spain", @query.registration_country_slug('andorra')
        end
        should "give the original if no mapping exists" do
          assert_equal "spain", @query.registration_country_slug('spain')
        end
      end
    end
  end
end
