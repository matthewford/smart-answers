require_relative "../../test_helper"
require_relative "../../../lib/smart_answer/date_helper"

module SmartAnswer::Calculators
  class MaternityPaternityCalculatorTest < ActiveSupport::TestCase
    include DateHelper

    context MaternityPaternityCalculator do
      context "due date 4 months in future" do
        setup do
          @due_date = 4.months.since(Date.today)
          @start_of_week_in_four_months = @due_date - @due_date.wday
          @calculator = MaternityPaternityCalculator.new(@due_date)
        end

        should "calculate expected birth week" do
          assert_equal @start_of_week_in_four_months, @calculator.expected_week.first
        end

        should "calculate qualifying week" do
          assert_equal 15.weeks.ago(@start_of_week_in_four_months), @calculator.qualifying_week.first
        end

        should "calculate notice of leave deadline" do
          assert_equal next_saturday(15.weeks.ago(@start_of_week_in_four_months)), @calculator.notice_of_leave_deadline
        end

        should "calculate the earliest leave start date" do
          assert_equal 11.weeks.ago(@start_of_week_in_four_months), @calculator.leave_earliest_start_date
        end

        should "calculate the relevant period" do
          @dd = Date.parse("2012-10-12")
          @calculator = MaternityPaternityCalculator.new(@dd)
          @calculator.last_payday = @calculator.qualifying_week.last
          payday = @calculator.last_payday.julian - (7 * 9)
          @calculator.pre_offset_payday = payday
          assert_equal "Saturday, 15 April 2012 and Saturday, 30 June 2012", @calculator.formatted_relevant_period
        end

        should "calculate payday offset" do
          @calculator.last_payday = Date.parse("2012-03-28")
          assert_equal Date.parse("2012-02-02"), @calculator.payday_offset
        end

        should "calculate the ssp_stop date" do
          @calculator = MaternityPaternityCalculator.new(Date.parse("2012 Oct 12"))
          expected_week = @calculator.expected_week.first
          assert_equal expected_week.julian - (7 * 4), @calculator.ssp_stop
        end

        context "with a requested leave date in one month's time" do
          setup do
            @leave_start_date = 1.month.since(Date.parse("2013 Mar 12"))
            @calculator.leave_start_date = @leave_start_date
          end

          should "make the leave end date 52 weeks from the leave start date" do
            assert_equal Date.parse("2014 Apr 10"), @calculator.leave_end_date
          end

          should "make the leave end date after the leave start date" do
            assert @calculator.leave_end_date > @calculator.leave_start_date, "Leave end date should come after leave start date"
          end

          should "make the pay start date the same date" do
            assert_equal @leave_start_date, @calculator.pay_start_date
          end

          should "make the pay end date 39 weeks from the start date" do
            assert_equal 39.weeks.since(@leave_start_date) - 1, @calculator.pay_end_date
          end

          should "have a notice request date 28 days before the leave start date" do
            assert_equal 28.days.ago(@leave_start_date), @calculator.notice_request_pay
          end
        end

        context "with a weekly income of 193.00" do
          setup do
            @calculator.average_weekly_earnings = 193.00
          end

          should "calculate the statutory maternity rate" do
            assert_equal (193.00 * 0.9).round(2), @calculator.statutory_maternity_rate
          end

          should "calculate the maternity pay at rate A" do
            assert_equal (193.00 * 0.9).round(2), @calculator.statutory_maternity_rate_a
          end

          should "calculate the maternity pay at rate B using the base rate" do
            assert_equal 135.45, @calculator.statutory_maternity_rate_b
          end

          should "calculate the maternity pay at rate B using the percentage of weekly income" do
            @calculator.average_weekly_earnings = 135.40
            assert_equal 121.87, @calculator.statutory_maternity_rate_b
          end

        end

        should "calculate the paternity rate as the standard rate" do
          @calculator.average_weekly_earnings = 500.55
          assert_equal 135.45, @calculator.statutory_paternity_rate
        end

        should "calculate the paternity rate as 90 percent of weekly earnings" do
          @calculator.average_weekly_earnings = 120.55
          assert_equal ((120.55 * 0.9).to_f).round(2), @calculator.statutory_paternity_rate
        end

        context "with an adoption placement date of a week ago" do
          setup do
            @one_week_ago = 1.week.ago(Date.today)
            @calculator.adoption_placement_date = @one_week_ago
          end

          should "make the earliest leave start date 14 days before the placement date" do
            assert_equal 1.fortnight.ago(@one_week_ago), @calculator.leave_earliest_start_date
          end
        end
      end

      context "specific date tests (for lower_earning_limits) for birth" do
        should "return lower_earning_limit 107" do
          @due_date = Date.parse("1 January 2013")
          @calculator = MaternityPaternityCalculator.new(@due_date)
          assert_equal @calculator.lower_earning_limit, 107
        end

        should "return lower_earning_limit 107" do
          @due_date = Date.parse("15 July 2012")
          @calculator = MaternityPaternityCalculator.new(@due_date)
          assert_equal @calculator.lower_earning_limit, 107
        end

        should "return lower_earning_limit 102" do
          @due_date = Date.parse("14 July 2012")
          @calculator = MaternityPaternityCalculator.new(@due_date)
          assert_equal @calculator.lower_earning_limit, 102
        end

        should "return lower_earning_limit 102" do
          @due_date = Date.parse("1 January 2012")
          @calculator = MaternityPaternityCalculator.new(@due_date)
          assert_equal @calculator.lower_earning_limit, 102
        end

        should "return lower_earning_limit 97" do
          @due_date = Date.parse("1 January 2011")
          @calculator = MaternityPaternityCalculator.new(@due_date)
          assert_equal @calculator.lower_earning_limit, 97
        end

        should "return lower_earning_limit 95" do
          @due_date = Date.parse("1 January 2010")
          @calculator = MaternityPaternityCalculator.new(@due_date)
          assert_equal @calculator.lower_earning_limit, 95
        end
      end

      context "specific date tests (for lower_earning_limits) for adoption" do
        should "return lower_earning_limit 107" do
          @match_date = Date.parse("1 April 2012")
          @calculator = MaternityPaternityCalculator.new(@match_date, MaternityPaternityCalculator::LEAVE_TYPE_ADOPTION)
          assert_equal @calculator.lower_earning_limit, 107
        end

        should "return lower_earning_limit 102" do
          @match_date = Date.parse("31 March 2012")
          @calculator = MaternityPaternityCalculator.new(@match_date, MaternityPaternityCalculator::LEAVE_TYPE_ADOPTION)
          assert_equal @calculator.lower_earning_limit, 102
        end

        should "return lower_earning_limit 97" do
          @match_date = Date.parse("2 April 2011")
          @calculator = MaternityPaternityCalculator.new(@match_date, MaternityPaternityCalculator::LEAVE_TYPE_ADOPTION)
          assert_equal @calculator.lower_earning_limit, 97
        end
      end

      context "qualifying_week tests" do
        # due, qualifying_week, latest employment start, start of 11th week before due, start of 4th week
        # 08/04/12 to 14/04/12 25/12/11 to 31/12/11 09/07/2011 22/01/2012 11/03/2012
        should "due Monday 9th April 2012" do
          @due_date = Date.parse("2012 Apr 09")
          @calculator = MaternityPaternityCalculator.new(@due_date)
          assert_equal Date.parse("09 Apr 2012"), @calculator.employment_end
          assert_equal Date.parse("08 Apr 2012")..Date.parse("14 Apr 2012"), @calculator.expected_week
          assert_equal Date.parse("25 Dec 2011"), 15.weeks.ago(@calculator.expected_week.first)
          assert_equal Date.parse("31 Dec 2011"), 15.weeks.ago(@calculator.expected_week.first) + 6
          assert_equal Date.parse("25 Dec 2011")..Date.parse("31 Dec 2011"), @calculator.qualifying_week
          # assert_equal 26, (Date.parse(" Dec 2011").julian - Date.parse("09 Jul 2011").julian).to_i / 7
          # assert_equal 26, (Date.parse("14 Apr 2012").julian - Date.parse("15 Oct 2011").julian).to_i / 7
          # FIXME: this should work but 25 weeks rather than 26
          assert_equal Date.parse("09 Jul 2011"), @calculator.employment_start
          assert_equal Date.parse("22 Jan 2012"), @calculator.leave_earliest_start_date
          assert_equal Date.parse("11 Mar 2012"), @calculator.ssp_stop
        end
        # 15/07/12 to 21/07/12 01/04/12 to 07/04/12 15/10/2011 29/04/2012 17/06/2012
        should "due Wednesday 18 July 2012" do
          @due_date = Date.parse("2012 Jul 18")
          @calculator = MaternityPaternityCalculator.new(@due_date)
          assert_equal Date.parse("18 Jul 2012"), @calculator.employment_end
          assert_equal Date.parse("15 Jul 2012")..Date.parse("21 Jul 2012"), @calculator.expected_week
          assert_equal Date.parse("01 Apr 2012")..Date.parse("07 Apr 2012"), @calculator.qualifying_week
          # DEBUG test
          # assert_equal 26, (Date.parse("21 Jul 2012").julian - Date.parse("15 Oct 2011").julian).to_i / 7
          # FIXME: ...
          assert_equal Date.parse("15 Oct 2011"), @calculator.employment_start
          assert_equal Date.parse("29 Apr 2012"), @calculator.leave_earliest_start_date
          assert_equal Date.parse("17 Jun 2012"), @calculator.ssp_stop
        end
        # 09/09/12 to 15/09/12 27/05/12 to 02/06/12 10/12/2011 24/06/2012 12/08/2012
        should "due Wednesday 14 Sep 2012" do
          @due_date = Date.parse("2012 Sep 14")
          @calculator = MaternityPaternityCalculator.new(@due_date)
          assert_equal Date.parse("14 Sep 2012"), @calculator.employment_end
          assert_equal Date.parse("09 Sep 2012")..Date.parse("15 Sep 2012"), @calculator.expected_week
          assert_equal Date.parse("27 May 2012")..Date.parse("02 Jun 2012"), @calculator.qualifying_week
          assert_equal Date.parse("10 Dec 2011"), @calculator.employment_start
          assert_equal Date.parse("24 Jun 2012"), @calculator.leave_earliest_start_date
          assert_equal Date.parse("12 Aug 2012"), @calculator.ssp_stop
        end
        # 07/04/13 to 13/04/13 23/12/12 to 29/12/12 07/07/2012 20/01/2013 10/03/2013
        # 27/01/13 to 02/02/13 14/10/12 to 20/10/12 28/04/2012 11/11/2012 30/12/2012
        # 03/02/13 to 09/02/13 21/10/12 to 27/10/12 05/05/2012 18/11/2012 06/01/2013
      end

      context "adoption employment start tests" do
        # 27/05/12 to 02/06/12 10/12/11
        should "matched_date Monday 28th May 2012" do
          @matched_date = Date.parse("2012 May 28")
          @calculator = MaternityPaternityCalculator.new(@matched_date, MaternityPaternityCalculator::LEAVE_TYPE_ADOPTION)
          assert_equal Date.parse("2012 May 27")..Date.parse("2012 Jun 02"), @calculator.matched_week
          assert_equal Date.parse("2011 Dec 10"), @calculator.a_employment_start
        end
        # 15/07/12 to 21/07/12 28/01/12
        should "matched_date Wednesday 18th July 2012" do
          @matched_date = Date.parse("2012 Jul 18")
          @calculator = MaternityPaternityCalculator.new(@matched_date, MaternityPaternityCalculator::LEAVE_TYPE_ADOPTION)
          assert_equal Date.parse("2012 Jul 15")..Date.parse("2012 Jul 21"), @calculator.matched_week
          assert_equal Date.parse("2012 Jan 28"), @calculator.a_employment_start
          assert_equal 25, (Date.parse("2012 Jul 21").julian - Date.parse("2012 Jan 28").julian).to_i / 7
        end
        # 16/09/12 to 22/09/12 31/03/12
        # 09/12/12 to 15/12/12 23/06/12
        # 10/03/13 to 16/03/13 22/09/12
      end

      context "calculate_average_weekly_pay" do
        setup do
          @calculator = MaternityPaternityCalculator.new(4.months.since(Date.today))
        end

        should "make no calculation for a weekly pay pattern" do
          assert_equal 665.15, @calculator.calculate_average_weekly_pay("weekly", 5321.20)
        end

        should "work out the weekly average for a fortnightly pay pattern" do
          assert_equal 399.32, @calculator.calculate_average_weekly_pay("every_2_weeks", 3194.56)
        end

        should "work out the weekly average for a four week pay pattern" do
          assert_equal 382.06, @calculator.calculate_average_weekly_pay("every_4_weeks", 3056.48)
        end

        should "work out the weekly average for a monthly pay pattern" do
          assert_equal 1846.15385, @calculator.calculate_average_weekly_pay("monthly", 16000)
        end

        should "work out the weekly average for a irregular pay pattern" do
          @calculator.last_payday = 15.days.ago(Date.today)
          @calculator.pre_offset_payday = 55.days.ago(@calculator.last_payday)
          assert_equal 56, @calculator.pay_period_in_days
          assert_equal 974.82875, @calculator.calculate_average_weekly_pay("irregularly", 7798.63)
        end
      end
      context "HMRC scenarios" do
        setup do
          @calculator = MaternityPaternityCalculator.new(Date.parse("2013-02-22"))
        end

        should "calculate AWE for weekly pay patterns" do
          assert_equal 200, @calculator.calculate_average_weekly_pay("weekly", 1600)
          assert_equal 151, @calculator.calculate_average_weekly_pay("weekly", 1208)
          assert_equal 150, @calculator.calculate_average_weekly_pay("weekly", 1200)
        end

        should "calculate AWE for monthly pay patterns" do
          @calculator.last_payday = Date.parse("2012-10-31")
          assert_equal 184.61538, @calculator.calculate_average_weekly_pay("monthly", 1600)
          @calculator.last_payday = Date.parse("2012-10-26")
          assert_equal 144.31731, @calculator.calculate_average_weekly_pay("monthly", 1250.75)
        end

        should "calculate AWE for irregular pay patterns" do
          @calculator.last_payday = Date.parse("2012-11-06")
          @calculator.pre_offset_payday = Date.parse("2012-08-01")
          assert_equal 214.28571, @calculator.calculate_average_weekly_pay("irregularly", 3000)
        end
      end

      context "total_statutory_pay" do
        setup do
          @calculator = MaternityPaternityCalculator.new(4.months.since(Date.today))
        end

        should "be statutory leave times statutory rates A and B" do
          @calculator.average_weekly_earnings = 120.40
          assert_equal 4226.43, @calculator.total_statutory_pay
        end

        should "be statutory leave times statutory higher rate A and statutory rate B" do
          @calculator.average_weekly_earnings = 235.40
          assert_equal 5741.01, @calculator.total_statutory_pay
        end
      end
    end
  end
end
