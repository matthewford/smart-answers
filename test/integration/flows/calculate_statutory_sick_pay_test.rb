# encoding: UTF-8
require_relative '../../test_helper'
require_relative 'flow_test_helper'

class CalculateStatutorySickPayTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    setup_for_testing_flow 'calculate-statutory-sick-pay'
  end

  	should "ask if employee is getting maternity pay" do
  		assert_current_node :getting_maternity_pay?
  	end

  	context "answered yes to maternity" do
  		should "return already_receiving_benefit on maternity answer" do
  			add_response :yes
			assert_current_node :already_receiving_benefit 
		end
	end

	context "answered no to maternity " do
		setup {add_response :no}
	  
	 	should "ask if employee is getting paternity or adoption pay"  do
	  		assert_current_node :getting_paternity_or_adoption_pay?
	  	end

	  	context "answer yes to paternity" do
	  		setup {add_response :yes}

	  		should "have set warning message flag and ask if employee was sick less then four days" do
	  			assert_state_variable "getting_paternity_or_adoption_pay", "yes"
	  			assert_current_node :sick_less_than_four_days?
	  		end

	  		context "answer yes to less than four days" do
	  			should "return must_be_sick_for_at_least_4_days outcome on sick_less_than_four_days " do
						add_response :yes
						assert_current_node :must_be_sick_for_at_least_4_days 	
					end
				end
			
	  		context "answer no to less than four days" do
	  			setup {add_response :no}

	  			should "ask if they told you within seven days" do
	  				assert_current_node :have_told_you_they_were_sick?
	  			end

	  			context "answer no to told within 7 days" do
	  				should "return not_informed_soon_enough outcome on havent_told_you_they_were_sick" do
							add_response :no
							assert_current_node	:not_informed_soon_enough			
						end
					end

	  			context "answer yes to told within 7 days" do
	  				setup {add_response :yes}

	  				should "ask if they normally work different days" do
	  					assert_current_node :different_days?
	  				end

	  				context "answer yes to irregular work schedule" do
							should "return irregular_work_schedule outcome on different_days" do
								add_response :yes
								assert_current_node :irregular_work_schedule 		
							end
	  				end

	  				context "answer no to irregular schedule" do
	  					setup {add_response :no}

	  					should "ask for sickness start date" do
	  						assert_current_node :sickness_start_date?
	  					end

	  					context "answer 10 September 2012" do
	  						setup {add_response Date.parse('10 September 2012')}
	  				
	  						should "ask for sickness end date" do
	  							assert_current_node :sickness_end_date?
	  						end

	  						context "answer 12 September 2012" do
	  							setup {add_response Date.parse('12 September 2012')}

	  							should "display no pay because not enough days sick" do
			  						assert_current_node :must_be_sick_for_at_least_4_days
			  					end
			  				end

	  						context "answer 20 September 2012" do
	  							setup {add_response Date.parse('20 September 2012')}

	  							should "ask if employee was paid for at least eight weeks" do
		  							assert_current_node :employee_paid_for_last_8_weeks?
		  						end

		  						context "answer yes to at least 8 weeks" do
		  							setup {add_response :yes}

		  							should "ask what were average weekly earnings" do
		  								assert_current_node :what_was_average_weekly_earnings?
		  							end

		  							context "earnings too low - 95.50" do
		  								setup {add_response 95.50}

		  								should "display not earned enough" do
		  									assert_current_node :not_earned_enough
		  								end
		  							end

		  							context "earnings high enough - £250.25" do
		  								setup {add_response 250.25}

		  								should "ask if they had a related illness" do
		  									assert_state_variable "over_eight_awe", 250.25
		  									assert_current_node :related_illness?
		  								end

		  								context "no related illness" do
		  									setup {add_response :no}

		  									should "ask how many days they work" do
		  										assert_current_node :which_days_worked?
		  									end

		  									context "answer Mon-Fri to days worked" do
		  										setup {add_response '1,2,3,4,5'}

		  										should "entitled to pay" do
		  											assert_state_variable "normal_workdays_out", 9
		  											assert_phrase_list :outcome_text, [:entitled_info]
		  											assert_current_node :entitled_or_not_enough_days
		  										end
		  										
		  									end # which days worked
		  								end # no related illness	
		  							end # earnings high enough
		  						end # yes to 8 weeks

		  						context "answer no to at least 8 weeks" do
		  							setup {add_response :no}

		  							should "ask what was average weekly pay when they got sick" do
		  								assert_current_node :what_was_average_weekly_pay?
		  							end

		  							context "avg weekly pay of 250.25" do
	  									setup {add_response 250.25}

	  									should "ask if they had related illness" do
	  										assert_state_variable "under_eight_awe", 250.25
	  										assert_current_node :related_illness?
	  									end

	  									context "no to related illness" do
	  										setup {add_response :no}

	  										should "ask how many days worked" do
	  											assert_current_node :which_days_worked?
	  										end

	  										context "M-F worked" do
			  									setup {add_response '1,2,3,4,5'}

										  		should "should display an outcome" do
			  										assert_state_variable "pattern_days", 5
			  										assert_state_variable "normal_workdays_out", 9
			  										assert_current_node :entitled_or_not_enough_days
			  									end

			  								end # 5 days worked
			  							end # no to related illness
			  						
			  							context "yes to related illness" do
			  							 	setup {add_response :yes}

			  							 	should "ask how many days missed" do
			  							 		assert_current_node :how_many_days_missed?
			  							 	end

			  								context "days missed" do
			  									should "return an error if 0" do
	  												add_response '0'
	  												assert_current_node_is_error
	  												assert_current_node :how_many_days_missed?
	  											end

	  											should "return an error if text" do
	  												add_response 'sometext'
	  												assert_current_node_is_error
	  												assert_current_node :how_many_days_missed?
													end

										  		context "answered 3 sick days during related illness" do
											  		setup {add_response '3'}
											  		
											  		should "ask which days they work" do
											  			assert_state_variable "prev_sick_days", 3
											  			assert_current_node :which_days_worked?
											  		end

											  		context "enter text" do
												  		setup {add_response 'sometext'}
												  		
												  		should "return an error if text" do
												  			assert_current_node_is_error
												  			assert_current_node :which_days_worked?
												  		end
												  	end
										  	
											  		context "M-W worked" do
												  		setup {add_response '1,2,3'}

												  		should "display result" do
												  			assert_state_variable "pattern_days", 3
												  			assert_current_node :entitled_or_not_enough_days
												  		end
											  		end
											  	end # 3 sick days	missed

											  	context "answered 115 sick days during related illness" do
											  		setup do 
											  			add_response 115 # 28 * 4 + 3
											  			add_response '1,2,3,4' # 4 pattern days
											  		end

											  		should "display not entitled because max paid previously for 4 pattern days" do
											  			assert_current_node :not_entitled_maximum_reached
											  		end
											  	end

											  	context "answered 143 sick days during related illness" do
											  		setup do 
											  			add_response 143 # 28 * 5 + 3
											  			add_response '1,2,3,4,5' # 5 pattern days
											  		end

											  		should "display not entitled because max paid previously for 5 pattern days" do
											  			assert_current_node :not_entitled_maximum_reached
											  		end
											  	end

												end # how many days missed
			  							end # yes to related illness
			  						end # weekly pay

			  						should "return earnings too low outcome on 90.25" do
	  									add_response 90.25
	  									assert_current_node :not_earned_enough
	  								end

			  					end # no to 8 weeks
			  				end #end date
			  			end # start date	

			  			context "previous tax year LEL test" do
			  				setup do
			  					add_response Date.parse("1 March 2012")
			  					add_response Date.parse("1 May 2012")
			  					add_response 'yes'
			  					add_response 103.00
			  				end

			  				should "ask if they had relate illness" do
	  							assert_current_node :related_illness?
	  						end
	  					end

	  					context "2013/14 LEL test" do
	  						setup do
	  							add_response Date.parse("10 April 2013")
	  							add_response Date.parse("10 May 2013")
	  							add_response 'yes'
	  							add_response 108.00
	  						end

	  						should "say not entitled because weekly earnings too low" do
	  							assert_current_node :not_earned_enough
	  						end
	  					end

			  		end #no to irregular schedule
		  		end # told within 7 days
		  	end # no to less than four days
		end # yes to paternity adoption
	end
end