
require_relative "../../test_helper"

module SmartAnswer::Calculators
  class StatutorySickPayCalculatorTest < ActiveSupport::TestCase

  	context StatutorySickPayCalculator do
  		context "prev_sick_days is 5, M-F, 7 days out" do
	  		setup do
	  			@start_date = Date.parse("1 October 2012")
	  			@calculator = StatutorySickPayCalculator.new(5, @start_date, Date.parse("7 October 2012"), ['1', '2', '3', '4', '5'])
	  		end

	  		should "return waiting_days of 0" do
	  			assert_equal @calculator.waiting_days, 0
	  		end

	  		should "return daily rate of 17.1700" do
	  			@weekly_rate = @calculator.weekly_rate_on(@start_date)
	  			assert_equal @weekly_rate, 85.8500
	  			assert_equal @calculator.daily_rate_from_weekly(@weekly_rate, 5), 17.1700
	  		end

	  		should "normal working days missed is 5" do
	  			assert_equal @calculator.normal_workdays, 5
	  		end

	  		should "return correct ssp_payment" do
	  			assert_equal @calculator.ssp_payment, 85.85
	  		end
	  	end

	  	context "daily rate test for 3 days per week worked (M-W-F)" do
	  		setup do
	  			@start_date = Date.parse("1 October 2012")
	  			@calculator = StatutorySickPayCalculator.new(5, @start_date, Date.parse("7 October 2012"), ['1', '3', '5'])
	  		end

	  		should "return daily rate of 28.6166" do
	  			assert_equal @calculator.daily_rate_from_weekly(@calculator.weekly_rate_on(@start_date), 3), 28.6166 # should be 28.6166 according to HMRC table
	  		end
	  	end

			context "daily rate test for 7 days per week worked" do
	  		setup do
	  			@start_date = Date.parse("1 October 2012")
	  			@calculator = StatutorySickPayCalculator.new(5, @start_date, Date.parse("7 October 2012"), ['0','1', '2', '3', '4','5','6'])
	  		end

	  		should "return daily rate of 12.2642" do
	  			assert_equal @calculator.daily_rate_from_weekly(@calculator.weekly_rate_on(@start_date), 7), 12.2642 # unrounded, matches the HMRC SSP daily rate table
	  		end
	  	end

			context "daily rate test for 6 days per week worked" do
	  		setup do
	  			@start_date = Date.parse("1 October 2012")
	  			@calculator = StatutorySickPayCalculator.new(5, @start_date, Date.parse("7 October 2012"), ['1', '2', '3', '4','5','6'])
	  		end

	  		should "return daily rate of 14.3083" do
	  			assert_equal @calculator.daily_rate_from_weekly(@calculator.weekly_rate_on(@start_date), 6), 14.3083 
	  		end
	  	end

	  	context "daily rate test for 2 days per week worked" do
	  		setup do
	  			@start_date = Date.parse("1 October 2012")
	  			@calculator = StatutorySickPayCalculator.new(5, @start_date, Date.parse("7 October 2012"), ['4','5'])
	  		end

	  		should "return daily rate of 42.9250" do
	  			assert_equal @calculator.daily_rate_from_weekly(@calculator.weekly_rate_on(@start_date), 2), 42.9250 
	  		end
	  	end

	  	context "waiting days if prev_sick_days is 2" do
	  		setup {@calculator = StatutorySickPayCalculator.new(2, Date.parse("6 April 2012"), Date.parse("6 May 2012"), ['1','2','3'])}

	  		should "return waiting_days of 1" do
	  			assert_equal @calculator.waiting_days, 1
	  		end
	  	end

			context "waiting days if prev_sick_days is 1" do
	  		setup {@calculator = StatutorySickPayCalculator.new(1, Date.parse("6 April 2012"), Date.parse("17 April 2012"), ['1','2','3'])}

	  		should "return waiting_days of 2" do
	  			assert_equal @calculator.waiting_days, 2
	  			assert_equal @calculator.normal_workdays, 5
	  			assert_equal @calculator.days_to_pay, 3
	  			
	  		end
	  	end

	  	context "waiting days if prev_sick_days is 0" do
	  		setup {@calculator = StatutorySickPayCalculator.new(0, Date.parse("6 April 2012"), Date.parse("12 April 2012"), ['1','2','3'])}

	  		should "return waiting_days of 3, ssp payment of 0" do
	  			assert_equal @calculator.waiting_days, 3
	  			assert_equal @calculator.days_to_pay, 0
	  			assert_equal @calculator.normal_workdays, 3	
	  			assert_equal @calculator.ssp_payment, 0.00
	  		end
	  	end

	  	context "maximum days payable for 5 days a week" do
				setup {@calculator = StatutorySickPayCalculator.new(0, Date.parse("6 April 2012"), Date.parse("6 December 2012"), ['1','2','3','4','5'])}

				should "have a max of 140 days payable" do
					assert_equal @calculator.days_to_pay, 140
					assert_equal @calculator.normal_workdays, 175
					assert_equal @calculator.ssp_payment, 2403.80 #140 * 17.1700 or 28 * 85.85
				end
			end

			context "maximum days payable for 3 days a week" do
				setup {@calculator = StatutorySickPayCalculator.new(0, Date.parse("6 April 2012"), Date.parse("6 December 2012"), ['2','3','4'])}

				should "have a max of 84 days payable" do
					assert_equal @calculator.days_to_pay, 84
					assert_equal @calculator.normal_workdays, 105
					assert_equal @calculator.ssp_payment, 2403.80 #28 weeks at 85.85 a week
				end
			end

			
			context "historic rate test 1" do
	  		setup do
	  			@start_date = Date.parse("5 April 2012")
	  			@calculator = StatutorySickPayCalculator.new(3, @start_date, Date.parse("10 April 2012"), ['1','2','3','4','5'])
	  		end

	  		should "use ssp rate and lel for 2011-12" do
	  			assert_equal StatutorySickPayCalculator.lower_earning_limit_on(@start_date), 102
	  			assert_equal @calculator.daily_rate_from_weekly(@calculator.weekly_rate_on(@start_date), 5), 16.3200
	  		end
	  	end

	  	# Monday - Friday
	  	context "test scenario 1 - M-F, no waiting days, cross tax years" do 
	  		setup do 
	  			@start_date = Date.parse("26 March 2012")
	  			@calculator = StatutorySickPayCalculator.new(0, @start_date, Date.parse("13 April 2012"), ['1','2','3','4','5'])
	  		end

	  		should "give correct ssp calculation" do  # 15 days with 3 waiting days, so 6 days at lower weekly rate, 6 days at higher rate
	  			assert_equal @calculator.waiting_days, 3
	  			assert_equal @calculator.days_to_pay, 12
	  			assert_equal @calculator.normal_workdays, 15
	  			assert_equal @calculator.ssp_payment, 200.94
	  		end
	  	end


		# Tuesday to Friday
			context "test scenario 2 - T-F, 7 waiting days, cross tax years" do 
	  		setup do 
	  			@calculator = StatutorySickPayCalculator.new(7, Date.parse("28 February 2012"), Date.parse("7 April 2012"), ['2','3','4','5'])
	  		end

	  		should "give correct ssp calculation" do # 24 days with no waiting days, so 22 days at lower weekly rate, 2 days at higher rate
	  			assert_equal @calculator.normal_workdays, 24
	  			assert_equal @calculator.days_to_pay, 24
	  			assert_equal @calculator.ssp_payment, 490.67
	  		end
	  	end

	  	# Monday, Wednesday, Friday
			context "test scenario 3" do 
	  		setup do 
	  			@calculator = StatutorySickPayCalculator.new(24, Date.parse("25 July 2012"), Date.parse("4 September 2012"), ['1', '3', '5'])
	  		end

	  		should "give correct ssp calculation" do # 18 days with no waiting days, all at 2012-13 daily rate
	  			assert_equal @calculator.days_to_pay, 18
	  			assert_equal @calculator.ssp_payment, 515.10
	  		end
	  	end

	  	#  Saturday and Sunday
	  	context "test scenario 4" do
	  		setup do 
	  			@calculator = StatutorySickPayCalculator.new(0, Date.parse("23 November 2012"), Date.parse("31 December 2012"), ['0','6'])
	  		end

	  		should "give correct ssp calculation" do # 12 days with 3 waiting days, all at 2012-13 daily rate
	  			assert_equal @calculator.waiting_days, 3
	  			assert_equal @calculator.days_to_pay, 9
	  			assert_equal @calculator.normal_workdays, 12
	  			assert_equal @calculator.ssp_payment, 386.33
	  		end
	  	end

	 		# Monday - Thursday
	  	context "test scenario 5" do
	  		setup do 
	  			@calculator = StatutorySickPayCalculator.new(99, Date.parse("29 March 2012"), Date.parse("6 May 2012"), ['1','2','3','4'])
	  		end

	  		should "give correct ssp calculation" do # max of 16 days that can still be paid with no waiting days, first four days at 2011-12,  2012-13 daily rate
	  			assert_equal @calculator.days_to_pay, 16
	  			assert_equal @calculator.ssp_payment, 338.09
	  		end
	  	end


	   	# Monday - Thursday
	  	context "test scenario 6" do
	  		setup do 
	  			@calculator = StatutorySickPayCalculator.new(115, Date.parse("29 March 2012"), Date.parse("6 May 2012"), ['1','2','3','4'])
	  		end

	  		should "give correct ssp calculation" do # there should be no more days for which employee can receive pay
	  			assert_equal @calculator.ssp_payment, 0
	  		end
	  	end

	  	# Wednesday
	  	context "test scenario 7" do
	  		setup do 
	  			@calculator = StatutorySickPayCalculator.new(0, Date.parse("28 August 2012"), Date.parse("6 October 2012"), ['3'])
	  		end

	  		should "give correct ssp calculation" do # there should be 3 normal workdays to pay
	  			assert_equal @calculator.days_to_pay, 3
	  			assert_equal @calculator.waiting_days, 3
	  			assert_equal @calculator.ssp_payment, 257.55
	  		end
	  	end

	  	#  additional test scenario - rates for previous tax year
	  	context "test scenario 6a - 1 day max to pay" do
	  		setup do 
	  			@calculator = StatutorySickPayCalculator.new(114, Date.parse("29 March 2012"), Date.parse("10 April 2012"), ['1','2','3','4'])
	  		end

	  		should "give correct ssp calculation" do # there should be max 1 day for which employee can receive pay
	  			assert_equal @calculator.days_to_pay, 1
	  			assert_equal @calculator.ssp_payment, 20.40
	  		end
	  	end

	  	# new test scenario 2 - SSP spanning 2013/14 tax year, Tue - Thu, rate above LEL, no previous sickness
	  	context "2013/14 test scenario 1" do
	  		setup do
	  			@calculator = StatutorySickPayCalculator.new(0, Date.parse("26 March 2013"), Date.parse("12 April 2013"), ['2','3','4'])
	  		end

	  		should "give correct SSP calculation" do
	  			assert_equal @calculator.days_to_pay, 6 # first 3 days are waiting days, so no pay
	  			assert_equal @calculator.ssp_payment, 172.55 # one week at 85.85 plus one week at 86.70
	  		end
	  	end

		# new test scenario 2 - SSP spanning 2013/14 tax year, Mon - Thu, no previous sickness
		context "2013/14 test scenario 2" do
	  		setup do
	  			@calculator = StatutorySickPayCalculator.new(0, Date.parse("7 January 2013"), Date.parse("3 May 2013"), ['1','2','3','4'])
	  		end

	  		should "give correct SSP calculation" do
	  			assert_equal @calculator.days_to_pay, 65 # 1 day + 16 weeks (4 days/week)
	  			assert_equal @calculator.ssp_payment, 1398.47 # see spreadsheet
	  		end
	  	end

	  	# new test scenario 3 - SSP spanning 2013/14 tax year, Wed and Sat, previous sickness of 8 days
		context "2013/14 test scenario 3" do
	  		setup do
	  			@calculator = StatutorySickPayCalculator.new(8, Date.parse("7 January 2013"), Date.parse("3 May 2013"), ['3','6'])
	  		end

	  		should "give correct SSP calculation" do
	  			assert_equal @calculator.days_to_pay, 33 # 1 day + 16 weeks (2 days/week)
	  			assert_equal @calculator.ssp_payment, 1419.93 # see spreadsheet
	  		end
	  	end

	  	# new test scenario 4 - SSP spanning 2013/14 tax year, Tue, Wed, Thu previous sickness of 42 days
		context "2013/14 test scenario 4" do
	  		setup do
	  			@calculator = StatutorySickPayCalculator.new(42, Date.parse("7 January 2013"), Date.parse("3 May 2013"), ['2','3','4'])
	  		end

	  		should "give correct SSP calculation" do
	  			assert_equal @calculator.days_to_pay, 45 # 15 weeks (3 days/week)
	  			assert_equal @calculator.ssp_payment, 1289.45 # see spreadsheet
	  		end
	  	end

	  	context "LEL test 1" do
	 		setup do
	 			@date = Date.parse("1 April 2012") 
	 			@lel = StatutorySickPayCalculator.lower_earning_limit_on(@date)
	  		end

	  		should "give correct LEL for date" do
	  			assert_equal @lel, 102.00
	  		end
	  	end

	  	context "LEL test 2" do
	  		setup do
	  			@date = Date.parse("6 April 2012")
	  			@lel = StatutorySickPayCalculator.lower_earning_limit_on(@date)
	  		end

	  		should "give correct LEL for date" do
	  			assert_equal @lel, 107.00
	  		end
	  	end

	  	context "LEL test 3" do
	  		setup do
	  			@date = Date.parse("6 April 2013")
	  			@lel = StatutorySickPayCalculator.lower_earning_limit_on(@date)
	  		end

	  		should "give correct LEL for date" do
	  			assert_equal @lel, 109.00
	  		end
	  	end

	  end # SSP calculator	 
  end
end
