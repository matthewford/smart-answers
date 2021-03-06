# encoding: UTF-8
require_relative '../../test_helper'
require_relative 'flow_test_helper'

class MarriageAbroadV2Test < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    setup_for_testing_flow 'marriage-abroad-v2'
  end

  should "which country you want the ceremony to take place in" do
    assert_current_node :country_of_ceremony?
  end
  context "ceremony in ireland" do
    setup do
      add_response 'ireland'
    end
    should "go to partner's sex question" do
      assert_current_node :partner_opposite_or_same_sex?
    end
    context "partner is opposite sex" do
      setup do
        add_response 'opposite_sex'
      end
      should "give outcome ireland os" do
        assert_current_node :outcome_ireland
        assert_phrase_list :ireland_partner_sex_variant, [:outcome_ireland_opposite_sex]
      end
    end
    context "partner is same sex" do
      setup do
        add_response 'same_sex'
      end
      should "give outcome ireland ss" do
        assert_current_node :outcome_ireland
        assert_phrase_list :ireland_partner_sex_variant, [:outcome_ireland_same_sex]
      end
    end
  end


  context "ceremony is outside ireland" do
    setup do
      add_response 'bahamas'
    end
    should "ask your country of residence" do
      assert_current_node :legal_residency?
      assert_state_variable :ceremony_country, 'bahamas'
      assert_state_variable :ceremony_country_name, 'Bahamas'
    end

    context "resident in UK" do
      setup do
        add_response 'uk'
      end
      should "go to uk residency region question" do
        assert_current_node :residency_uk?
        assert_state_variable :ceremony_country, 'bahamas'
        assert_state_variable :ceremony_country_name, 'Bahamas'
        assert_state_variable :resident_of, 'uk'
      end

      context "resident in england" do
        setup do
          add_response 'uk_england'
        end
        should "go to partner nationality question" do
          assert_current_node :what_is_your_partners_nationality?
          assert_state_variable :ceremony_country, 'bahamas'
          assert_state_variable :ceremony_country_name, 'Bahamas'
          assert_state_variable :resident_of, 'uk'
          assert_state_variable :residency_uk_region, 'uk_england'
        end

        context "partner is british" do
          setup do
            add_response 'partner_british'
          end
          should "ask what sex is your partner" do
            assert_current_node :partner_opposite_or_same_sex?
            assert_state_variable :partner_nationality, 'partner_british'
          end
          context "opposite sex partner" do
            setup do
              add_response 'opposite_sex'
            end
            should "give outcome opposite sex commonwealth" do
              assert_current_node :outcome_os_commonwealth
              assert_phrase_list :commonwealth_os_outcome, [:commonwealth_os_all_intro, :uk_resident_os_ceremony_not_zimbabwe, :commonwealth_os_all_cni]
            end
          end
          context "same sex partner" do
            setup do
              add_response 'same_sex'
            end
            should "give outcome same sex all other countries" do
              assert_current_node :outcome_cp_all_other_countries
            end
          end
        end
      end
    end
    context "resident in non-UK country" do
      setup do
        add_response 'other'
      end
      should "go to non-uk residency country question" do
        assert_current_node :residency_nonuk?
        assert_state_variable :ceremony_country, 'bahamas'
        assert_state_variable :ceremony_country_name, 'Bahamas'
        assert_state_variable :resident_of, 'other'
      end

      context "resident in australia" do
        setup do
          add_response 'australia'
        end
        should "go to partner's nationality question" do
          assert_current_node :what_is_your_partners_nationality?
          assert_state_variable :ceremony_country, 'bahamas'
          assert_state_variable :ceremony_country_name, 'Bahamas'
          assert_state_variable :resident_of, 'other'
          assert_state_variable :residency_country, 'australia'
          assert_state_variable :residency_country_name, 'Australia'
        end
        context "partner is local" do
          setup do
            add_response 'partner_local'
          end
          should "ask what sex is your partner" do
            assert_current_node :partner_opposite_or_same_sex?
            assert_state_variable :partner_nationality, 'partner_local'
          end
          context "opposite sex partner" do
            setup do
              add_response 'opposite_sex'
            end
            should "give outcome opposite sex commonwealth" do
              assert_current_node :outcome_os_commonwealth
              assert_phrase_list :commonwealth_os_outcome, [:commonwealth_os_all_intro, :other_resident_os_ceremony_not_zimbabwe, :commonwealth_os_all_cni, :commonwealth_os_naturalisation]
            end
          end
          context "same sex partner" do
            setup do
              add_response 'same_sex'
            end
            should "give outcome all other countries" do
              assert_current_node :outcome_cp_all_other_countries
            end
          end
        end
      end
    end
  end

# tests for specific countries
# testing for zimbabwe variants
  context "local resident but ceremony not in zimbabwe" do
    setup do
      add_response 'australia'
      add_response 'other'
      add_response 'australia'
      add_response 'partner_british'
      add_response 'opposite_sex'
    end
    should "go to commonwealth os outcome" do
      assert_current_node :outcome_os_commonwealth
      assert_phrase_list :commonwealth_os_outcome, [:commonwealth_os_all_intro, :local_resident_os_ceremony_not_zimbabwe, :commonwealth_os_all_cni]
    end
  end
  context "uk resident but ceremony not in zimbabwe" do
    setup do
      add_response 'bahamas'
      add_response 'uk'
      add_response 'uk_england'
      add_response 'partner_british'
      add_response 'opposite_sex'
    end
    should "go to commonwealth os outcome" do
      assert_current_node :outcome_os_commonwealth
      assert_phrase_list :commonwealth_os_outcome, [:commonwealth_os_all_intro, :uk_resident_os_ceremony_not_zimbabwe, :commonwealth_os_all_cni]
    end
  end
  context "other resident but ceremony not in zimbabwe" do
    setup do
      add_response 'australia'
      add_response 'other'
      add_response 'canada'
      add_response 'partner_british'
      add_response 'opposite_sex'
    end
    should "go to commonwealth os outcome" do
      assert_current_node :outcome_os_commonwealth
      assert_phrase_list :commonwealth_os_outcome, [:commonwealth_os_all_intro, :other_resident_os_ceremony_not_zimbabwe, :commonwealth_os_all_cni]
    end
  end
  context "uk resident ceremony in zimbabwe" do
    setup do
      add_response 'zimbabwe'
      add_response 'uk'
      add_response 'uk_wales'
      add_response 'partner_british'
      add_response 'opposite_sex'
    end
    should "go to commonwealth os outcome" do
      assert_current_node :outcome_os_commonwealth
      assert_phrase_list :commonwealth_os_outcome, [:commonwealth_os_zimbabwe_intro, :uk_resident_os_ceremony_zimbabwe, :commonwealth_os_all_cni_zimbabwe]
    end
  end
# testing for other commonwealth countries
  context "uk resident ceremony in south-africa" do
    setup do
      add_response 'south-africa'
      add_response 'uk'
      add_response 'uk_wales'
      add_response 'partner_local'
      add_response 'opposite_sex'
    end
    should "go to commonwealth os outcome" do
      assert_current_node :outcome_os_commonwealth
      assert_phrase_list :commonwealth_os_outcome, [:commonwealth_os_all_intro, :uk_resident_os_ceremony_not_zimbabwe, :commonwealth_os_all_cni, :commonwealth_os_other_countries_south_africe, :commonwealth_os_naturalisation]
    end
  end
  context "resident in cyprus, ceremony in cyprus" do
    setup do
      add_response 'cyprus'
      add_response 'other'
      add_response 'cyprus'
      add_response 'partner_irish'
      add_response 'opposite_sex'
    end
    should "go to commonwealth os outcome" do
      assert_current_node :outcome_os_commonwealth
      assert_phrase_list :commonwealth_os_outcome, [:commonwealth_os_all_intro, :local_resident_os_ceremony_not_zimbabwe, :commonwealth_os_all_cni, :commonwealth_os_other_countries_cyprus, :commonwealth_os_naturalisation]
    end
  end
# testing for british overseas territories
  context "uk resident ceremony in british indian ocean territory" do
    setup do
      add_response 'british-indian-ocean-territory'
      add_response 'uk'
      add_response 'uk_wales'
      add_response 'partner_local'
      add_response 'opposite_sex'
    end
    should "go to bot os outcome" do
      assert_current_node :outcome_os_bot
      assert_phrase_list :bot_outcome, [:bot_os_ceremony_biot]
    end
  end
  context "resident in anguilla, ceremony in anguilla" do
    setup do
      add_response 'anguilla'
      add_response 'other'
      add_response 'anguilla'
      add_response 'partner_irish'
      add_response 'opposite_sex'
    end
    should "go to bos os outcome" do
      assert_current_node :outcome_os_bot
      assert_phrase_list :bot_outcome, [:bot_os_ceremony_non_biot, :bot_os_naturalisation]
    end
  end
# testing for consular cni countries
  context "uk resident, ceremony in estonia, partner british" do
    setup do
      add_response 'estonia'
      add_response 'uk'
      add_response 'uk_wales'
      add_response 'partner_british'
      add_response 'opposite_sex'
    end
    should "go to consular cni os outcome" do
      assert_current_node :outcome_os_consular_cni
      assert_phrase_list :consular_cni_os_start, [:uk_resident_os_consular_cni, :consular_cni_all_what_you_need_to_do, :uk_resident_partner_not_irish_os_consular_cni_three, :consular_cni_os_uk_resident_not_italy_two]
      assert_phrase_list :consular_cni_os_remainder, [:consular_cni_os_partner_british, :consular_cni_os_all_names, :consular_cni_os_all_depositing_certificate, :consular_cni_os_no_clickbook_so_embassy_details, :consular_cni_os_uk_resident, :consular_cni_os_all_fees, :consular_cni_os_fees_local_currency]
    end
  end
  context "resident in estonia, ceremony in estonia" do
    setup do
      add_response 'estonia'
      add_response 'other'
      add_response 'estonia'
      add_response 'partner_local'
      add_response 'opposite_sex'
    end
    should "go to consular cni os outcome" do
      assert_current_node :outcome_os_consular_cni
      assert_phrase_list :consular_cni_os_start, [:local_resident_os_consular_cni, :consular_cni_all_what_you_need_to_do, :consular_cni_os_local_resident_not_italy_germany, :consular_cni_os_no_clickbook_so_embassy_details, :consular_cni_variant_local_resident_not_germany_or_spain_or_foreign_resident, :consular_cni_os_local_resident_not_germany_or_spain_or_all_other_residency, :consular_cni_variant_local_resident_not_germany_or_spain_or_foreign_resident_two, :consular_cni_os_local_resident_not_germany_or_italy]
      assert_phrase_list :consular_cni_os_remainder, [:consular_cni_os_all_names, :consular_cni_os_other_resident_ceremony_not_italy, :consular_cni_os_naturalisation, :consular_cni_os_all_depositing_certificate, :consular_cni_os_all_fees, :consular_cni_os_fees_local_currency]
    end
  end
  context "resident in canada, ceremony in estonia" do
    setup do
      add_response 'estonia'
      add_response 'other'
      add_response 'canada'
      add_response 'partner_other'
      add_response 'opposite_sex'
    end
    should "go to consular cni os outcome" do
      assert_current_node :outcome_os_consular_cni
      assert_phrase_list :consular_cni_os_start, [:other_resident_os_consular_cni, :consular_cni_all_what_you_need_to_do, :consular_cni_os_commonwealth_resident, :consular_cni_os_commonwealth_resident_two, :consular_cni_os_commonwealth_or_ireland_resident_non_british_partner, :consular_cni_os_local_resident_not_germany_or_spain_or_all_other_residency, :consular_cni_os_commonwealth_resident_ceremony_not_italy]
      assert_phrase_list :consular_cni_os_remainder, [:consular_cni_os_all_names, :consular_cni_os_other_resident_ceremony_not_italy, :consular_cni_os_naturalisation, :consular_cni_os_all_depositing_certificate, :consular_cni_os_no_clickbook_so_embassy_details, :consular_cni_os_all_fees, :consular_cni_os_fees_local_currency]
    end
  end
  context "local resident, ceremony in jordan, partner british" do
    setup do
      add_response 'jordan'
      add_response 'other'
      add_response 'jordan'
      add_response 'partner_british'
      add_response 'opposite_sex'
    end
    should "go to consular cni os outcome" do
      assert_current_node :outcome_os_consular_cni
      assert_phrase_list :consular_cni_os_start, [:local_resident_os_consular_cni, :gulf_states_os_consular_cni, :gulf_states_os_consular_cni_local_resident_partner_not_irish, :consular_cni_all_what_you_need_to_do, :consular_cni_os_local_resident_not_italy_germany, :consular_cni_os_no_clickbook_so_embassy_details, :consular_cni_variant_local_resident_not_germany_or_spain_or_foreign_resident, :consular_cni_os_local_resident_not_germany_or_spain_or_all_other_residency, :consular_cni_variant_local_resident_not_germany_or_spain_or_foreign_resident_two, :consular_cni_os_local_resident_not_germany_or_italy]
      assert_phrase_list :consular_cni_os_remainder, [:consular_cni_os_partner_british, :consular_cni_os_all_names, :consular_cni_os_other_resident_ceremony_not_italy, :consular_cni_os_all_depositing_certificate, :consular_cni_os_all_fees, :consular_cni_os_fees_no_cheques]
    end
  end
# variants for italy
  context "ceremony in italy" do
    setup do
      add_response 'italy'
      add_response 'uk'
      add_response 'uk_england'
      add_response 'partner_british'
      add_response 'opposite_sex'
    end
    should "go to consular cni os outcome" do
      assert_current_node :outcome_os_consular_cni
      assert_phrase_list :consular_cni_os_start, [:uk_resident_os_consular_cni, :consular_cni_all_what_you_need_to_do, :consular_cni_os_italy_scenario_one, :uk_resident_partner_not_irish_os_consular_cni_three, :consular_cni_os_scotland_or_ni_partner_irish_or_partner_not_irish_three]
      assert_phrase_list :consular_cni_os_remainder, [:consular_cni_os_ceremony_italy, :consular_cni_os_partner_british, :consular_cni_os_all_names, :consular_cni_os_all_depositing_certificate, :clickbook_links, :consular_cni_os_uk_resident, :consular_cni_os_all_fees, :consular_cni_os_fees_no_cheques, :consular_cni_os_outcome_spain_or_italy]
      assert_phrase_list :consular_cni_os_remainder, [:consular_cni_os_ceremony_italy, :consular_cni_os_partner_british, :consular_cni_os_all_names, :consular_cni_os_all_depositing_certificate, :clickbook_links, :consular_cni_os_uk_resident, :consular_cni_os_all_fees, :consular_cni_os_fees_no_cheques, :consular_cni_os_outcome_spain_or_italy]
    end
  end
#variants for denmark
  context "ceremony in denmark, resident in canada, partner irish" do
    setup do
      add_response 'denmark'
      add_response 'other'
      add_response 'canada'
      add_response 'partner_irish'
      add_response 'opposite_sex'
    end
    should "go to consular cni os outcome" do
      assert_current_node :outcome_os_consular_cni
      assert_phrase_list :consular_cni_os_start, [:other_resident_os_consular_cni, :consular_cni_all_what_you_need_to_do, :consular_cni_os_denmark, :consular_cni_os_commonwealth_resident, :consular_cni_os_commonwealth_resident_two, :consular_cni_os_commonwealth_or_ireland_resident_non_british_partner, :consular_cni_os_local_resident_not_germany_or_spain_or_all_other_residency, :consular_cni_os_commonwealth_resident_ceremony_not_italy]
      assert_phrase_list :consular_cni_os_remainder, [:consular_cni_os_all_names, :consular_cni_os_other_resident_ceremony_not_italy, :consular_cni_os_naturalisation, :consular_cni_os_all_depositing_certificate, :consular_cni_os_no_clickbook_so_embassy_details, :consular_cni_os_all_fees, :consular_cni_os_fees_no_cheques]
    end
  end
#variants for germany
  context "ceremony in germany, resident in germany, partner irish" do
    setup do
      add_response 'germany'
      add_response 'other'
      add_response 'germany'
      add_response 'partner_irish'
      add_response 'opposite_sex'
    end
    should "go to consular cni os outcome" do
      assert_current_node :outcome_os_consular_cni
      assert_phrase_list :consular_cni_os_start, [:local_resident_os_consular_cni, :consular_cni_all_what_you_need_to_do, :consular_cni_os_german_resident, :consular_cni_os_local_resident_not_italy_germany, :consular_cni_os_no_clickbook_so_embassy_details]
      assert_phrase_list :consular_cni_os_remainder, [:consular_cni_os_all_names, :consular_cni_os_other_resident_ceremony_not_italy, :consular_cni_os_naturalisation, :consular_cni_os_all_depositing_certificate, :consular_cni_os_no_clickbook_so_embassy_details, :consular_cni_os_all_fees, :consular_cni_os_fees_no_cheques]
    end
  end
#variants for uk residency (again)
  context "ceremony in turkey, resident in isle of man, partner non-irish" do
    setup do
      add_response 'turkey'
      add_response 'uk'
      add_response 'uk_iom'
      add_response 'partner_local'
      add_response 'opposite_sex'
    end
    should "go to consular cni os outcome" do
      assert_current_node :outcome_os_consular_cni
      assert_phrase_list :consular_cni_os_start, [:uk_resident_os_consular_cni, :consular_cni_all_what_you_need_to_do, :uk_resident_partner_not_irish_os_consular_cni_three, :consular_cni_os_uk_resident_not_italy_two]
      assert_phrase_list :consular_cni_os_remainder, [:consular_cni_os_all_names, :consular_cni_os_naturalisation, :consular_cni_os_all_depositing_certificate, :consular_cni_os_no_clickbook_so_embassy_details, :consular_cni_os_ceremony_turkey, :consular_cni_os_uk_resident, :consular_cni_os_all_fees, :consular_cni_os_fees_no_cheques]
    end
  end
  context "ceremony in turkey, resident in northern ireland, partner irish" do
    setup do
      add_response 'turkey'
      add_response 'uk'
      add_response 'uk_ni'
      add_response 'partner_irish'
      add_response 'opposite_sex'
    end
    should "go to consular cni os outcome" do
      assert_current_node :outcome_os_consular_cni
      assert_phrase_list :consular_cni_os_start, [:uk_resident_os_consular_cni, :consular_cni_all_what_you_need_to_do, :scotland_ni_resident_partner_irish_os_consular_cni_three, :consular_cni_os_uk_resident_not_italy_two]
      assert_phrase_list :consular_cni_os_remainder, [:consular_cni_os_all_names, :consular_cni_os_naturalisation, :consular_cni_os_all_depositing_certificate, :consular_cni_os_no_clickbook_so_embassy_details, :consular_cni_os_ceremony_turkey, :consular_cni_os_uk_resident, :consular_cni_os_all_fees, :consular_cni_os_fees_no_cheques]
    end
  end
#variant for england and wales, irish partner - ceremony not italy
  context "ceremony in peru, resident in wales, partner irish" do
    setup do
      add_response 'peru'
      add_response 'uk'
      add_response 'uk_wales'
      add_response 'partner_irish'
      add_response 'opposite_sex'
    end
    should "go to consular cni os outcome" do
      assert_current_node :outcome_os_consular_cni
      assert_phrase_list :consular_cni_os_start, [:uk_resident_os_consular_cni, :consular_cni_all_what_you_need_to_do, :consular_cni_os_england_or_wales_resident_not_italy, :consular_cni_os_uk_resident_not_italy_two]
      assert_phrase_list :consular_cni_os_remainder, [:consular_cni_os_all_names, :consular_cni_os_naturalisation, :consular_cni_os_all_depositing_certificate, :clickbook_link, :consular_cni_os_uk_resident, :consular_cni_os_all_fees, :consular_cni_os_fees_no_cheques]
    end
  end
#variant for uk resident, ceremony not in italy
  context "ceremony in peru, resident in wales, partner other" do
    setup do
      add_response 'peru'
      add_response 'uk'
      add_response 'uk_wales'
      add_response 'partner_other'
      add_response 'opposite_sex'
    end
    should "go to consular cni os outcome" do
      assert_current_node :outcome_os_consular_cni
      assert_phrase_list :consular_cni_os_start, [:uk_resident_os_consular_cni, :consular_cni_all_what_you_need_to_do, :uk_resident_partner_not_irish_os_consular_cni_three, :consular_cni_os_uk_resident_not_italy_two]
      assert_phrase_list :consular_cni_os_remainder, [:consular_cni_os_all_names, :consular_cni_os_naturalisation, :consular_cni_os_all_depositing_certificate, :clickbook_link, :consular_cni_os_uk_resident, :consular_cni_os_all_fees, :consular_cni_os_fees_no_cheques]
    end
  end
#variant for local resident, ceremony not in italy or germany
  context "ceremony in turkey, resident in turkey, partner other" do
    setup do
      add_response 'turkey'
      add_response 'other'
      add_response 'turkey'
      add_response 'partner_other'
      add_response 'opposite_sex'
    end
    should "go to consular cni os outcome" do
      assert_current_node :outcome_os_consular_cni
      assert_phrase_list :consular_cni_os_start, [:local_resident_os_consular_cni, :consular_cni_all_what_you_need_to_do, :consular_cni_os_local_resident_not_italy_germany, :consular_cni_os_no_clickbook_so_embassy_details, :consular_cni_variant_local_resident_not_germany_or_spain_or_foreign_resident, :consular_cni_os_local_resident_not_germany_or_spain_or_all_other_residency, :consular_cni_variant_local_resident_not_germany_or_spain_or_foreign_resident_two, :consular_cni_os_local_resident_not_germany_or_italy]
      assert_phrase_list :consular_cni_os_remainder, [:consular_cni_os_all_names, :consular_cni_os_other_resident_ceremony_not_italy, :consular_cni_os_naturalisation, :consular_cni_os_all_depositing_certificate, :consular_cni_os_ceremony_turkey, :consular_cni_os_all_fees, :consular_cni_os_fees_no_cheques]
    end
  end
  context "ceremony in portugal, resident in portugal, partner other" do
    setup do
      add_response 'portugal'
      add_response 'other'
      add_response 'portugal'
      add_response 'partner_other'
      add_response 'opposite_sex'
    end
    should "go to consular cni os outcome" do
      assert_current_node :outcome_os_consular_cni
      assert_phrase_list :consular_cni_os_start, [:local_resident_os_consular_cni, :consular_cni_all_what_you_need_to_do, :consular_cni_os_local_resident_not_italy_germany, :clickbook_links, :consular_cni_variant_local_resident_not_germany_or_spain_or_foreign_resident, :consular_cni_os_local_resident_not_germany_or_spain_or_all_other_residency, :consular_cni_variant_local_resident_not_germany_or_spain_or_foreign_resident_two, :consular_cni_os_local_resident_not_germany_or_italy]
      assert_phrase_list :consular_cni_os_remainder, [:consular_cni_os_all_names, :consular_cni_os_other_resident_ceremony_not_italy, :consular_cni_os_naturalisation, :consular_cni_os_all_depositing_certificate, :consular_cni_os_all_fees, :consular_cni_os_fees_no_cheques]
    end
  end

#variants for commonwealth or ireland resident
  context "ceremony in switzerland, resident in canada, partner british" do
    setup do
      add_response 'switzerland'
      add_response 'other'
      add_response 'canada'
      add_response 'partner_british'
      add_response 'opposite_sex'
    end
    should "go to consular cni os outcome" do
      assert_current_node :outcome_os_consular_cni
      assert_phrase_list :consular_cni_os_start, [:other_resident_os_consular_cni, :consular_cni_all_what_you_need_to_do, :consular_cni_os_commonwealth_resident, :consular_cni_os_commonwealth_resident_british_partner, :consular_cni_os_commonwealth_resident_two, :consular_cni_os_commonwealth_or_ireland_resident_british_partner, :consular_cni_os_local_resident_not_germany_or_spain_or_all_other_residency, :consular_cni_os_commonwealth_resident_ceremony_not_italy]
      assert_phrase_list :consular_cni_os_remainder, [:consular_cni_os_partner_british, :consular_cni_os_all_names, :consular_cni_os_other_resident_ceremony_not_italy, :consular_cni_os_all_depositing_certificate, :clickbook_link, :consular_cni_os_all_fees, :consular_cni_os_fees_no_cheques]
    end
  end
  context "ceremony in switzerland, resident in ireland, partner british" do
    setup do
      add_response 'switzerland'
      add_response 'other'
      add_response 'ireland'
      add_response 'partner_british'
      add_response 'opposite_sex'
    end
    should "go to consular cni os outcome" do
      assert_current_node :outcome_os_consular_cni
      assert_phrase_list :consular_cni_os_start, [:other_resident_os_consular_cni, :consular_cni_all_what_you_need_to_do, :consular_cni_os_ireland_resident]
      assert_phrase_list :consular_cni_os_remainder, []
    end
  end
#variants for ireland residents
  context "ceremony in switzerland, resident in ireland, partner british" do
    setup do
      add_response 'switzerland'
      add_response 'other'
      add_response 'ireland'
      add_response 'partner_british'
      add_response 'opposite_sex'
    end
    should "go to consular cni os outcome" do
      assert_current_node :outcome_os_consular_cni
      assert_phrase_list :consular_cni_os_start, [:other_resident_os_consular_cni, :consular_cni_all_what_you_need_to_do, :consular_cni_os_ireland_resident, :consular_cni_os_ireland_resident_british_partner, :consular_cni_os_ireland_resident_two, :consular_cni_os_commonwealth_or_ireland_resident_british_partner, :consular_cni_os_local_resident_not_germany_or_spain_or_all_other_residency, :consular_cni_os_ireland_resident_ceremony_not_italy]
      assert_phrase_list :consular_cni_os_remainder, [:consular_cni_os_partner_british, :consular_cni_os_all_names, :consular_cni_os_other_resident_ceremony_not_italy, :consular_cni_os_all_depositing_certificate, :clickbook_link, :consular_cni_os_all_fees, :consular_cni_os_fees_no_cheques]
    end
  end
  context "ceremony in switzerland, resident in ireland, partner other" do
    setup do
      add_response 'switzerland'
      add_response 'other'
      add_response 'ireland'
      add_response 'partner_other'
      add_response 'opposite_sex'
    end
    should "go to consular cni os outcome" do
      assert_current_node :outcome_os_consular_cni
      assert_phrase_list :consular_cni_os_start, [:other_resident_os_consular_cni, :consular_cni_all_what_you_need_to_do, :consular_cni_os_ireland_resident, :consular_cni_os_ireland_resident_two, :consular_cni_os_commonwealth_or_ireland_resident_non_british_partner, :consular_cni_os_local_resident_not_germany_or_spain_or_all_other_residency, :consular_cni_os_ireland_resident_ceremony_not_italy]
      assert_phrase_list :consular_cni_os_remainder, [:consular_cni_os_all_names, :consular_cni_os_other_resident_ceremony_not_italy, :consular_cni_os_naturalisation, :consular_cni_os_all_depositing_certificate, :clickbook_link, :consular_cni_os_all_fees, :consular_cni_os_fees_no_cheques]
    end
  end
#variants for commonwealth or ireland residents
  context "ceremony in switzerland, resident in australia, partner british" do
    setup do
      add_response 'switzerland'
      add_response 'other'
      add_response 'australia'
      add_response 'partner_british'
      add_response 'opposite_sex'
    end
    should "go to consular cni os outcome" do
      assert_current_node :outcome_os_consular_cni
      assert_phrase_list :consular_cni_os_start, [:other_resident_os_consular_cni, :consular_cni_all_what_you_need_to_do, :consular_cni_os_commonwealth_resident, :consular_cni_os_commonwealth_resident_british_partner, :consular_cni_os_commonwealth_resident_two, :consular_cni_os_commonwealth_or_ireland_resident_british_partner, :consular_cni_os_local_resident_not_germany_or_spain_or_all_other_residency, :consular_cni_os_commonwealth_resident_ceremony_not_italy]
      assert_phrase_list :consular_cni_os_remainder, [:consular_cni_os_partner_british, :consular_cni_os_all_names, :consular_cni_os_other_resident_ceremony_not_italy, :consular_cni_os_all_depositing_certificate, :clickbook_link, :consular_cni_os_all_fees, :consular_cni_os_fees_no_cheques]
    end
  end
  context "ceremony in switzerland, resident in australia, partner other" do
    setup do
      add_response 'switzerland'
      add_response 'other'
      add_response 'australia'
      add_response 'partner_other'
      add_response 'opposite_sex'
    end
    should "go to consular cni os outcome" do
      assert_current_node :outcome_os_consular_cni
      assert_phrase_list :consular_cni_os_start, [:other_resident_os_consular_cni, :consular_cni_all_what_you_need_to_do, :consular_cni_os_commonwealth_resident, :consular_cni_os_commonwealth_resident_two, :consular_cni_os_commonwealth_or_ireland_resident_non_british_partner, :consular_cni_os_local_resident_not_germany_or_spain_or_all_other_residency, :consular_cni_os_commonwealth_resident_ceremony_not_italy]
      assert_phrase_list :consular_cni_os_remainder, [:consular_cni_os_all_names, :consular_cni_os_other_resident_ceremony_not_italy, :consular_cni_os_naturalisation, :consular_cni_os_all_depositing_certificate, :clickbook_link, :consular_cni_os_all_fees, :consular_cni_os_fees_no_cheques]
    end
  end
#variant for local residents (not germany or spain)
  context "ceremony in switzerland, resident in switzerland, partner other" do
    setup do
      add_response 'switzerland'
      add_response 'other'
      add_response 'switzerland'
      add_response 'partner_other'
      add_response 'opposite_sex'
    end
    should "go to consular cni os outcome" do
      assert_current_node :outcome_os_consular_cni
      assert_phrase_list :consular_cni_os_start, [:local_resident_os_consular_cni, :consular_cni_all_what_you_need_to_do, :consular_cni_os_local_resident_not_italy_germany, :clickbook_link, :consular_cni_variant_local_resident_not_germany_or_spain_or_foreign_resident, :consular_cni_os_local_resident_not_germany_or_spain_or_all_other_residency, :consular_cni_variant_local_resident_not_germany_or_spain_or_foreign_resident_two, :consular_cni_os_local_resident_not_germany_or_italy]
      assert_phrase_list :consular_cni_os_remainder, [:consular_cni_os_all_names, :consular_cni_os_other_resident_ceremony_not_italy, :consular_cni_os_naturalisation, :consular_cni_os_all_depositing_certificate, :consular_cni_os_all_fees, :consular_cni_os_fees_no_cheques]
    end
  end
#variant for foreign resident
  context "ceremony in turkey, resident in switzerland, partner other" do
    setup do
      add_response 'turkey'
      add_response 'other'
      add_response 'switzerland'
      add_response 'partner_other'
      add_response 'opposite_sex'
    end
    should "go to consular cni os outcome" do
      assert_current_node :outcome_os_consular_cni
      assert_phrase_list :consular_cni_os_start, [:other_resident_os_consular_cni, :consular_cni_all_what_you_need_to_do, :consular_cni_os_foreign_resident, :consular_cni_variant_local_resident_not_germany_or_spain_or_foreign_resident, :consular_cni_os_local_resident_not_germany_or_spain_or_all_other_residency, :consular_cni_variant_local_resident_not_germany_or_spain_or_foreign_resident_two, :consular_cni_os_foreign_resident_ceremony_not_italy]
      assert_phrase_list :consular_cni_os_remainder, [:consular_cni_os_all_names, :consular_cni_os_other_resident_ceremony_not_italy, :consular_cni_os_naturalisation, :consular_cni_os_all_depositing_certificate, :consular_cni_os_no_clickbook_so_embassy_details, :consular_cni_os_ceremony_turkey, :consular_cni_os_all_fees, :consular_cni_os_fees_no_cheques]
    end
  end
#variant for local resident - spain
  context "ceremony in spain" do
    setup do
      add_response 'spain'
      add_response 'uk'
      add_response 'uk_england'
      add_response 'partner_british'
      add_response 'opposite_sex'
    end
    should "go to consular cni os outcome" do
      assert_current_node :outcome_os_consular_cni
      assert_phrase_list :consular_cni_os_start, [:uk_resident_os_consular_cni, :spain_os_consular_cni, :consular_cni_all_what_you_need_to_do, :uk_resident_partner_not_irish_os_consular_cni_three, :consular_cni_os_uk_resident_not_italy_two]
      assert_phrase_list :consular_cni_os_remainder, [:consular_cni_os_partner_british, :consular_cni_os_all_names, :consular_cni_os_ceremony_spain, :consular_cni_os_ceremony_spain_partner_british, :consular_cni_os_ceremony_spain_two, :consular_cni_os_all_depositing_certificate, :consular_cni_os_no_clickbook_so_embassy_details, :consular_cni_os_uk_resident, :consular_cni_os_all_fees, :consular_cni_os_fees_no_cheques, :consular_cni_os_outcome_spain_or_italy]
    end
  end
#variant for local residents (not germany or spain) again
  context "ceremony in poland, resident in poland, partner local" do
    setup do
      add_response 'poland'
      add_response 'other'
      add_response 'poland'
      add_response 'partner_local'
      add_response 'opposite_sex'
    end
    should "go to consular cni os outcome" do
      assert_current_node :outcome_os_consular_cni
      assert_phrase_list :consular_cni_os_start, [:local_resident_os_consular_cni, :consular_cni_all_what_you_need_to_do, :consular_cni_os_local_resident_not_italy_germany, :consular_cni_os_no_clickbook_so_embassy_details, :consular_cni_variant_local_resident_not_germany_or_spain_or_foreign_resident, :consular_cni_os_local_resident_not_germany_or_spain_or_all_other_residency, :consular_cni_variant_local_resident_not_germany_or_spain_or_foreign_resident_two, :consular_cni_os_local_resident_not_germany_or_italy]
      assert_phrase_list :consular_cni_os_remainder, [:consular_cni_os_all_names, :consular_cni_os_other_resident_ceremony_not_italy, :consular_cni_os_naturalisation, :consular_cni_os_all_depositing_certificate, :consular_cni_os_all_fees, :consular_cni_os_fees_local_currency]
    end
  end
#variant for local resident (not germany or spain) or foreign residents
  context "ceremony in turkey, resident in switzerland, partner local" do
    setup do
      add_response 'turkey'
      add_response 'other'
      add_response 'switzerland'
      add_response 'partner_local'
      add_response 'opposite_sex'
    end
    should "go to consular cni os outcome" do
      assert_current_node :outcome_os_consular_cni
      assert_phrase_list :consular_cni_os_start, [:other_resident_os_consular_cni, :consular_cni_all_what_you_need_to_do, :consular_cni_os_foreign_resident, :consular_cni_variant_local_resident_not_germany_or_spain_or_foreign_resident, :consular_cni_os_local_resident_not_germany_or_spain_or_all_other_residency, :consular_cni_variant_local_resident_not_germany_or_spain_or_foreign_resident_two, :consular_cni_os_foreign_resident_ceremony_not_italy]
      assert_phrase_list :consular_cni_os_remainder, [:consular_cni_os_all_names, :consular_cni_os_other_resident_ceremony_not_italy, :consular_cni_os_naturalisation, :consular_cni_os_all_depositing_certificate, :consular_cni_os_no_clickbook_so_embassy_details, :consular_cni_os_ceremony_turkey, :consular_cni_os_all_fees, :consular_cni_os_fees_no_cheques]
    end
  end
  context "ceremony in turkey, resident in turkey, partner local" do
    setup do
      add_response 'turkey'
      add_response 'other'
      add_response 'turkey'
      add_response 'partner_local'
      add_response 'opposite_sex'
    end
    should "go to consular cni os outcome" do
      assert_current_node :outcome_os_consular_cni
      assert_phrase_list :consular_cni_os_start, [:local_resident_os_consular_cni, :consular_cni_all_what_you_need_to_do, :consular_cni_os_local_resident_not_italy_germany, :consular_cni_os_no_clickbook_so_embassy_details, :consular_cni_variant_local_resident_not_germany_or_spain_or_foreign_resident, :consular_cni_os_local_resident_not_germany_or_spain_or_all_other_residency, :consular_cni_variant_local_resident_not_germany_or_spain_or_foreign_resident_two, :consular_cni_os_local_resident_not_germany_or_italy]
      assert_phrase_list :consular_cni_os_remainder, [:consular_cni_os_all_names, :consular_cni_os_other_resident_ceremony_not_italy, :consular_cni_os_naturalisation, :consular_cni_os_all_depositing_certificate, :consular_cni_os_ceremony_turkey, :consular_cni_os_all_fees, :consular_cni_os_fees_no_cheques]
    end
  end
#variant for foreign resident, ceremony not in italy AND foreign resident, ceremony in italy
  context "ceremony in turkey, resident in poland, partner local" do
    setup do
      add_response 'turkey'
      add_response 'other'
      add_response 'poland'
      add_response 'partner_local'
      add_response 'opposite_sex'
    end
    should "go to consular cni os outcome" do
      assert_current_node :outcome_os_consular_cni
      assert_phrase_list :consular_cni_os_start, [:other_resident_os_consular_cni, :consular_cni_all_what_you_need_to_do, :consular_cni_os_foreign_resident, :consular_cni_variant_local_resident_not_germany_or_spain_or_foreign_resident, :consular_cni_os_local_resident_not_germany_or_spain_or_all_other_residency, :consular_cni_variant_local_resident_not_germany_or_spain_or_foreign_resident_two, :consular_cni_os_foreign_resident_ceremony_not_italy]
      assert_phrase_list :consular_cni_os_remainder, [:consular_cni_os_all_names, :consular_cni_os_other_resident_ceremony_not_italy, :consular_cni_os_naturalisation, :consular_cni_os_all_depositing_certificate, :consular_cni_os_no_clickbook_so_embassy_details, :consular_cni_os_ceremony_turkey, :consular_cni_os_all_fees, :consular_cni_os_fees_no_cheques]
    end
  end
#variant for commonwealth resident, ceremony not in italy AND ireland resident , ceremony not in italy
  context "ceremony in turkey, resident in canada, partner local" do
    setup do
      add_response 'turkey'
      add_response 'other'
      add_response 'canada'
      add_response 'partner_local'
      add_response 'opposite_sex'
    end
    should "go to consular cni os outcome" do
      assert_current_node :outcome_os_consular_cni
      assert_phrase_list :consular_cni_os_start, [:other_resident_os_consular_cni, :consular_cni_all_what_you_need_to_do, :consular_cni_os_commonwealth_resident, :consular_cni_os_commonwealth_resident_two, :consular_cni_os_commonwealth_or_ireland_resident_non_british_partner, :consular_cni_os_local_resident_not_germany_or_spain_or_all_other_residency, :consular_cni_os_commonwealth_resident_ceremony_not_italy]
      assert_phrase_list :consular_cni_os_remainder, [:consular_cni_os_all_names, :consular_cni_os_other_resident_ceremony_not_italy, :consular_cni_os_naturalisation, :consular_cni_os_all_depositing_certificate, :consular_cni_os_no_clickbook_so_embassy_details, :consular_cni_os_ceremony_turkey, :consular_cni_os_all_fees, :consular_cni_os_fees_no_cheques]
    end
  end
  context "ceremony in turkey, resident in ireland, partner local" do
    setup do
      add_response 'turkey'
      add_response 'other'
      add_response 'ireland'
      add_response 'partner_local'
      add_response 'opposite_sex'
    end
    should "go to consular cni os outcome" do
      assert_current_node :outcome_os_consular_cni
      assert_phrase_list :consular_cni_os_start, [:other_resident_os_consular_cni, :consular_cni_all_what_you_need_to_do, :consular_cni_os_ireland_resident, :consular_cni_os_ireland_resident_two, :consular_cni_os_commonwealth_or_ireland_resident_non_british_partner, :consular_cni_os_local_resident_not_germany_or_spain_or_all_other_residency, :consular_cni_os_ireland_resident_ceremony_not_italy]
      assert_phrase_list :consular_cni_os_remainder, [:consular_cni_os_all_names, :consular_cni_os_other_resident_ceremony_not_italy, :consular_cni_os_naturalisation, :consular_cni_os_all_depositing_certificate, :consular_cni_os_no_clickbook_so_embassy_details, :consular_cni_os_ceremony_turkey, :consular_cni_os_all_fees, :consular_cni_os_fees_no_cheques]
    end
  end

#tests using better code
#testing for ceremony in poland, british partner
  context "ceremony in poland, resident in ireland, partner british" do
    setup do
      add_response 'poland'
      add_response 'other'
      add_response 'ireland'
      add_response 'partner_british'
      add_response 'opposite_sex'
    end
    should "go to consular cni os outcome" do
      assert_current_node :outcome_os_consular_cni
      assert_phrase_list :consular_cni_os_start, [:other_resident_os_consular_cni, :consular_cni_all_what_you_need_to_do, :consular_cni_os_ireland_resident, :consular_cni_os_ireland_resident_british_partner, :consular_cni_os_ireland_resident_two, :consular_cni_os_commonwealth_or_ireland_resident_british_partner, :consular_cni_os_local_resident_not_germany_or_spain_or_all_other_residency, :consular_cni_os_ireland_resident_ceremony_not_italy]
      assert_phrase_list :consular_cni_os_remainder, [:consular_cni_os_partner_british, :consular_cni_os_all_names, :consular_cni_os_other_resident_ceremony_not_italy, :consular_cni_os_all_depositing_certificate, :consular_cni_os_no_clickbook_so_embassy_details, :consular_cni_os_all_fees, :consular_cni_os_fees_local_currency]
    end
  end
#testing for belgium variant
  context "ceremony in belgium, resident in ireland, partner british" do
    setup do
      add_response 'belgium'
      add_response 'other'
      add_response 'ireland'
      add_response 'partner_british'
      add_response 'opposite_sex'
    end
    should "go to consular cni os outcome" do
      assert_current_node :outcome_os_consular_cni
      assert_phrase_list :consular_cni_os_start, [:other_resident_os_consular_cni, :consular_cni_all_what_you_need_to_do, :consular_cni_os_ireland_resident, :consular_cni_os_ireland_resident_british_partner, :consular_cni_os_ireland_resident_two, :consular_cni_os_commonwealth_or_ireland_resident_british_partner, :consular_cni_os_local_resident_not_germany_or_spain_or_all_other_residency, :consular_cni_os_ireland_resident_ceremony_not_italy]
      assert_phrase_list :consular_cni_os_remainder, [:consular_cni_os_partner_british, :consular_cni_os_all_names, :consular_cni_os_other_resident_ceremony_not_italy, :consular_cni_os_ceremony_belgium, :consular_cni_os_belgium_clickbook, :consular_cni_os_all_depositing_certificate, :clickbook_link, :consular_cni_os_all_fees, :consular_cni_os_fees_no_cheques]
    end
  end
#testing for finland variant
  context "ceremony in finland, resident in ireland, partner other" do
    setup do
      add_response 'finland'
      add_response 'other'
      add_response 'ireland'
      add_response 'partner_other'
      add_response 'opposite_sex'
    end
    should "go to consular cni os outcome" do
      assert_current_node :outcome_os_consular_cni
      assert_phrase_list :consular_cni_os_start, [:other_resident_os_consular_cni, :consular_cni_all_what_you_need_to_do, :consular_cni_os_ireland_resident, :consular_cni_os_ireland_resident_two, :consular_cni_os_commonwealth_or_ireland_resident_non_british_partner, :consular_cni_os_local_resident_not_germany_or_spain_or_all_other_residency, :consular_cni_os_ireland_resident_ceremony_not_italy]
      assert_phrase_list :consular_cni_os_remainder, [:consular_cni_os_all_names, :consular_cni_os_other_resident_ceremony_not_italy, :consular_cni_os_naturalisation, :consular_cni_os_all_depositing_certificate, :consular_cni_os_no_clickbook_so_embassy_details, :consular_cni_os_ceremony_finland, :consular_cni_os_all_fees, :consular_cni_os_fees_no_cheques]
    end
  end
#testing for turkey variant
  context "ceremony in turkey, resident in ireland, partner other" do
    setup do
      add_response 'turkey'
      add_response 'other'
      add_response 'ireland'
      add_response 'partner_other'
      add_response 'opposite_sex'
    end
    should "go to consular cni os outcome" do
      assert_current_node :outcome_os_consular_cni
      assert_phrase_list :consular_cni_os_start, [:other_resident_os_consular_cni, :consular_cni_all_what_you_need_to_do, :consular_cni_os_ireland_resident, :consular_cni_os_ireland_resident_two, :consular_cni_os_commonwealth_or_ireland_resident_non_british_partner, :consular_cni_os_local_resident_not_germany_or_spain_or_all_other_residency, :consular_cni_os_ireland_resident_ceremony_not_italy]
      assert_phrase_list :consular_cni_os_remainder, [:consular_cni_os_all_names, :consular_cni_os_other_resident_ceremony_not_italy, :consular_cni_os_naturalisation, :consular_cni_os_all_depositing_certificate, :consular_cni_os_no_clickbook_so_embassy_details, :consular_cni_os_ceremony_turkey, :consular_cni_os_all_fees, :consular_cni_os_fees_no_cheques]
    end
  end
#testing for uk resident variant
  context "ceremony in turkey, resident in scotland, partner other" do
    setup do
      add_response 'turkey'
      add_response 'uk'
      add_response 'uk_scotland'
      add_response 'partner_other'
      add_response 'opposite_sex'
    end
    should "go to consular cni os outcome" do
      assert_current_node :outcome_os_consular_cni
      assert_phrase_list :consular_cni_os_start, [:uk_resident_os_consular_cni, :consular_cni_all_what_you_need_to_do, :uk_resident_partner_not_irish_os_consular_cni_three, :consular_cni_os_uk_resident_not_italy_two]
      assert_phrase_list :consular_cni_os_remainder, [:consular_cni_os_all_names, :consular_cni_os_naturalisation, :consular_cni_os_all_depositing_certificate, :consular_cni_os_no_clickbook_so_embassy_details, :consular_cni_os_ceremony_turkey, :consular_cni_os_uk_resident, :consular_cni_os_all_fees, :consular_cni_os_fees_no_cheques]
    end
  end
#testing for fee variant
  context "ceremony in armenia, resident in scotland, partner other" do
    setup do
      add_response 'armenia'
      add_response 'uk'
      add_response 'uk_scotland'
      add_response 'partner_other'
      add_response 'opposite_sex'
    end
    should "go to consular cni os outcome" do
      assert_current_node :outcome_os_consular_cni
      assert_phrase_list :consular_cni_os_start, [:uk_resident_os_consular_cni, :consular_cni_all_what_you_need_to_do, :uk_resident_partner_not_irish_os_consular_cni_three, :consular_cni_os_uk_resident_not_italy_two]
      assert_phrase_list :consular_cni_os_remainder, [:consular_cni_os_all_names, :consular_cni_os_naturalisation, :consular_cni_os_all_depositing_certificate, :consular_cni_os_no_clickbook_so_embassy_details, :consular_cni_os_uk_resident, :consular_cni_os_all_fees, :consular_cni_os_fees_local_currency]
    end
  end

#France or french overseas territories outcome
#testing for ceremony in France and UK resident
  context "ceremony in france, resident in scotland, partner other" do
    setup do
      add_response 'france'
      add_response 'uk'
      add_response 'uk_scotland'
      add_response 'partner_other'
      add_response 'opposite_sex'
    end
    should "go to consular cni os outcome" do
      assert_current_node :outcome_os_france_or_fot
      assert_phrase_list :france_or_fot_os_outcome, [:france_fot_os_ceremony_france_uk_resident, :france_fot_os_all_what_you_need_to_do, :france_fot_os_uk_resident_two, :france_fot_os_all_celibacy, :france_fot_os_naturalisation, :france_fot_os_all_depositing_certificate, :france_fot_os_uk_resident_two_point_five, :france_fot_os_all_multilingual_extract, :france_fot_os_uk_resident_three, :france_fot_os_all_fees]
    end
  end
#testing for ceremony in france, local resident
  context "ceremony in france, resident in france, partner other" do
    setup do
      add_response 'france'
      add_response 'other'
      add_response 'france'
      add_response 'partner_other'
      add_response 'opposite_sex'
    end
    should "go to consular cni os outcome" do
      assert_current_node :outcome_os_france_or_fot
      assert_phrase_list :france_or_fot_os_outcome, [:france_fot_os_ceremony_france_local_resident, :france_fot_os_all_what_you_need_to_do, :france_fot_os_not_uk_resident_two, :france_fot_os_all_celibacy, :france_fot_os_naturalisation, :france_fot_os_all_depositing_certificate, :france_fot_os_all_multilingual_extract, :france_fot_os_all_fees]
    end
  end
#testing for ceremony in france, other resident
  context "ceremony in france, resident in poland, partner other" do
    setup do
      add_response 'france'
      add_response 'other'
      add_response 'poland'
      add_response 'partner_other'
      add_response 'opposite_sex'
    end
    should "go to consular cni os outcome" do
      assert_current_node :outcome_os_france_or_fot
      assert_phrase_list :france_or_fot_os_outcome, [:france_fot_os_ceremony_france_other_resident, :france_fot_os_not_uk_resident, :france_fot_os_all_what_you_need_to_do, :france_fot_os_not_uk_resident_two, :france_fot_os_all_celibacy, :france_fot_os_naturalisation, :france_fot_os_all_depositing_certificate, :france_fot_os_all_fees]
    end
  end
#testing for ceremony in french overseas territories, uk resident
  context "ceremony in fot, resident in scotland, partner other" do
    setup do
      add_response 'mayotte'
      add_response 'uk'
      add_response 'uk_scotland'
      add_response 'partner_other'
      add_response 'opposite_sex'
    end
    should "go to consular cni os outcome" do
      assert_current_node :outcome_os_france_or_fot
      assert_phrase_list :france_or_fot_os_outcome, [:france_fot_os_ceremony_fot_uk_resident, :france_fot_os_all_what_you_need_to_do, :france_fot_os_uk_resident_two, :france_fot_os_all_celibacy, :france_fot_os_naturalisation, :france_fot_os_all_depositing_certificate, :france_fot_os_uk_resident_two_point_five, :france_fot_os_all_multilingual_extract, :france_fot_os_uk_resident_three, :france_fot_os_all_fees]
    end
  end
#testing for ceremony in fot, local resident
  context "ceremony in france, resident in mayotte, partner other" do
    setup do
      add_response 'mayotte'
      add_response 'other'
      add_response 'mayotte'
      add_response 'partner_other'
      add_response 'opposite_sex'
    end
    should "go to consular cni os outcome" do
      assert_current_node :outcome_os_france_or_fot
      assert_phrase_list :france_or_fot_os_outcome, [:france_fot_os_ceremony_fot_local_resident, :france_fot_os_all_what_you_need_to_do, :france_fot_os_not_uk_resident_two, :france_fot_os_all_celibacy, :france_fot_os_naturalisation, :france_fot_os_all_depositing_certificate, :france_fot_os_all_multilingual_extract, :france_fot_os_all_fees]
    end
  end
#testing for ceremony in fot, other resident
  context "ceremony in france, resident in poland, partner other" do
    setup do
      add_response 'mayotte'
      add_response 'other'
      add_response 'poland'
      add_response 'partner_other'
      add_response 'opposite_sex'
    end
    should "go to consular cni os outcome" do
      assert_current_node :outcome_os_france_or_fot
      assert_phrase_list :france_or_fot_os_outcome, [:france_fot_os_ceremony_fot_other_resident, :france_fot_os_all_what_you_need_to_do, :france_fot_os_not_uk_resident_two, :france_fot_os_all_celibacy, :france_fot_os_naturalisation, :france_fot_os_all_depositing_certificate, :france_fot_os_all_multilingual_extract, :france_fot_os_all_fees]
    end
  end

#tests for affirmation to marry outcomes
#testing for ceremony in thailand, uk resident, partner other
  context "ceremony in thailand, resident in scotland, partner other" do
    setup do
      add_response 'thailand'
      add_response 'uk'
      add_response 'uk_scotland'
      add_response 'partner_other'
      add_response 'opposite_sex'
    end
    should "go to consular cni os outcome" do
      assert_current_node :outcome_os_affirmation
      assert_phrase_list :affirmation_os_outcome, [:affirmation_os_uk_resident, :affirmation_os_all_what_you_need_to_do, :affirmation_os_partner_not_british, :affirmation_os_all_depositing_certificate, :affirmation_os_uk_resident_three, :affirmation_os_all_fees]
    end
  end
#testing for ceremony in egypt, local resident, partner british
  context "ceremony in egypt, resident in egypt, partner british" do
    setup do
      add_response 'egypt'
      add_response 'other'
      add_response 'egypt'
      add_response 'partner_british'
      add_response 'opposite_sex'
    end
    should "go to consular cni os outcome" do
      assert_current_node :outcome_os_affirmation
      assert_phrase_list :affirmation_os_outcome, [:affirmation_os_local_resident, :affirmation_os_all_what_you_need_to_do, :affirmation_os_partner_british, :affirmation_os_all_depositing_certificate, :affirmation_os_all_fees]
    end
  end
#testing for ceremony in korea, other resident, partner irish
  context "ceremony in lebanon, resident in poland, partner irish" do
    setup do
      add_response 'lebanon'
      add_response 'other'
      add_response 'poland'
      add_response 'partner_irish'
      add_response 'opposite_sex'
    end
    should "go to consular cni os outcome" do
      assert_current_node :outcome_os_affirmation
      assert_phrase_list :affirmation_os_outcome, [:affirmation_os_other_resident, :affirmation_os_all_what_you_need_to_do, :affirmation_os_partner_not_british, :affirmation_os_all_depositing_certificate, :affirmation_os_all_fees]
    end
  end

#tests for no cni or consular services
#testing for dutch caribbean islands
  context "ceremony in aruba, resident in scotland, partner other" do
    setup do
      add_response 'aruba'
      add_response 'uk'
      add_response 'uk_scotland'
      add_response 'partner_other'
      add_response 'opposite_sex'
    end
    should "go to consular cni os outcome" do
      assert_current_node :outcome_os_no_cni
      assert_phrase_list :no_cni_os_outcome, [:no_cni_os_dutch_caribbean_islands, :no_cni_os_dutch_caribbean_islands_uk_resident, :no_cni_os_all_nearest_embassy, :no_cni_os_all_depositing_certificate, :no_cni_os_ceremony_not_usa, :no_cni_os_uk_resident_three, :no_cni_os_all_fees, :no_cni_os_naturalisation]
    end
  end
#testing for ceremony in aruba, local resident, partner british
  context "ceremony in aruba, resident in aruba, partner british" do
    setup do
      add_response 'aruba'
      add_response 'other'
      add_response 'aruba'
      add_response 'partner_british'
      add_response 'opposite_sex'
    end
    should "go to consular cni os outcome" do
      assert_current_node :outcome_os_no_cni
      assert_phrase_list :no_cni_os_outcome, [:no_cni_os_dutch_caribbean_islands, :no_cni_os_dutch_caribbean_islands_local_resident, :no_cni_os_all_nearest_embassy, :no_cni_os_all_depositing_certificate, :no_cni_os_ceremony_not_usa, :no_cni_os_all_fees]
    end
  end
#testing for ceremony in aruba, other resident, partner irish
  context "ceremony in aruba, resident in poland, partner irish" do
    setup do
      add_response 'aruba'
      add_response 'other'
      add_response 'poland'
      add_response 'partner_irish'
      add_response 'opposite_sex'
    end
    should "go to consular cni os outcome" do
      assert_current_node :outcome_os_no_cni
      assert_phrase_list :no_cni_os_outcome, [:no_cni_os_dutch_caribbean_islands, :no_cni_os_dutch_caribbean_other_resident, :no_cni_os_all_nearest_embassy, :no_cni_os_all_depositing_certificate, :no_cni_os_ceremony_not_usa, :no_cni_os_all_fees, :no_cni_os_naturalisation]
    end
  end
#testing for non-dutch caribbean islands
  context "ceremony in monaco, resident in scotland, partner other" do
    setup do
      add_response 'monaco'
      add_response 'uk'
      add_response 'uk_scotland'
      add_response 'partner_other'
      add_response 'opposite_sex'
    end
    should "go to consular cni os outcome" do
      assert_current_node :outcome_os_no_cni
      assert_phrase_list :no_cni_os_outcome, [:no_cni_os_not_dutch_caribbean_islands_uk_resident, :no_cni_os_all_nearest_embassy, :no_cni_os_all_depositing_certificate, :no_cni_os_ceremony_not_usa, :no_cni_os_uk_resident_three, :no_cni_os_all_fees, :no_cni_os_naturalisation]
    end
  end
#testing for ceremony in monaco, local resident, partner british
  context "ceremony in monaco, resident in monaco, partner british" do
    setup do
      add_response 'monaco'
      add_response 'other'
      add_response 'monaco'
      add_response 'partner_british'
      add_response 'opposite_sex'
    end
    should "go to consular cni os outcome" do
      assert_current_node :outcome_os_no_cni
      assert_phrase_list :no_cni_os_outcome, [:no_cni_os_not_dutch_caribbean_islands_local_resident, :no_cni_os_all_nearest_embassy, :no_cni_os_all_depositing_certificate, :no_cni_os_ceremony_not_usa, :no_cni_os_all_fees]
    end
  end
#testing for ceremony in aruba, other resident, partner irish
  context "ceremony in monaco, resident in poland, partner irish" do
    setup do
      add_response 'monaco'
      add_response 'other'
      add_response 'poland'
      add_response 'partner_irish'
      add_response 'opposite_sex'
    end
    should "go to consular cni os outcome" do
      assert_current_node :outcome_os_no_cni
      assert_phrase_list :no_cni_os_outcome, [:no_cni_os_not_dutch_caribbean_other_resident, :no_cni_os_all_nearest_embassy, :no_cni_os_all_depositing_certificate, :no_cni_os_ceremony_not_usa, :no_cni_os_all_fees, :no_cni_os_naturalisation]
    end
  end
#testing for ceremony in usa
  context "ceremony in usa, resident in poland, partner irish" do
    setup do
      add_response 'united-states'
      add_response 'other'
      add_response 'poland'
      add_response 'partner_irish'
      add_response 'opposite_sex'
    end
    should "go to consular cni os outcome" do
      assert_current_node :outcome_os_no_cni
      assert_phrase_list :no_cni_os_outcome, [:no_cni_os_not_dutch_caribbean_other_resident, :no_cni_os_all_nearest_embassy, :no_cni_os_all_depositing_certificate, :no_cni_os_ceremony_usa, :no_cni_os_all_fees, :no_cni_os_naturalisation]
    end
  end

#testing for other countries
#testing for burma
  context "ceremony in burma, resident in scotland, partner local" do
    setup do
      add_response 'burma'
      add_response 'uk'
      add_response 'uk_scotland'
      add_response 'partner_local'
      add_response 'opposite_sex'
    end
    should "go to consular cni os outcome" do
      assert_current_node :outcome_os_other_countries
      assert_phrase_list :other_countries_os_outcome, [:other_countries_os_burma, :other_countries_os_burma_partner_local]
    end
  end
#testing for north korea
  context "ceremony in north korea, resident in scotland, partner local" do
    setup do
      add_response 'north-korea'
      add_response 'uk'
      add_response 'uk_scotland'
      add_response 'partner_local'
      add_response 'opposite_sex'
    end
    should "go to consular cni os outcome" do
      assert_current_node :outcome_os_other_countries
      assert_phrase_list :other_countries_os_outcome, [:other_countries_os_north_korea, :other_countries_os_north_korea_partner_local]
    end
  end
#testing for iran
  context "ceremony in iran, resident in scotland, partner local" do
    setup do
      add_response 'iran'
      add_response 'uk'
      add_response 'uk_scotland'
      add_response 'partner_local'
      add_response 'opposite_sex'
    end
    should "go to consular cni os outcome" do
      assert_current_node :outcome_os_other_countries
      assert_phrase_list :other_countries_os_outcome, [:other_countries_os_iran_somalia_syria]
    end
  end
#testing for yemen
  context "ceremony in yemen, resident in scotland, partner local" do
    setup do
      add_response 'yemen'
      add_response 'uk'
      add_response 'uk_scotland'
      add_response 'partner_local'
      add_response 'opposite_sex'
    end
    should "go to consular cni os outcome" do
      assert_current_node :outcome_os_other_countries
      assert_phrase_list :other_countries_os_outcome, [:other_countries_os_yemen]
    end
  end
#testing for saudi arabia, not local resident
  context "ceremony in saudi arabia, resident in scotland, partner other" do
    setup do
      add_response 'saudi-arabia'
      add_response 'uk'
      add_response 'uk_scotland'
      add_response 'partner_other'
      add_response 'opposite_sex'
    end
    should "go to consular cni os outcome" do
      assert_current_node :outcome_os_other_countries
      assert_phrase_list :other_countries_os_outcome, [:other_countries_os_ceremony_saudia_arabia_not_local_resident]
    end
  end
#testing for saudi arabia, local resident, partner irish
  context "ceremony in saudi arabia, resident in saudi arabia, partner irish" do
    setup do
      add_response 'saudi-arabia'
      add_response 'other'
      add_response 'saudi-arabia'
      add_response 'partner_irish'
      add_response 'opposite_sex'
    end
    should "go to consular cni os outcome" do
      assert_current_node :outcome_os_other_countries
      assert_phrase_list :other_countries_os_outcome, [:other_countries_os_saudi_arabia_local_resident_partner_irish]
    end
  end
#testing for saudi arabia, local resident, partner british
  context "ceremony in saudi arabia, resident in saudi arabia, partner british" do
    setup do
      add_response 'saudi-arabia'
      add_response 'other'
      add_response 'saudi-arabia'
      add_response 'partner_british'
      add_response 'opposite_sex'
    end
    should "go to consular cni os outcome" do
      assert_current_node :outcome_os_other_countries
      assert_phrase_list :other_countries_os_outcome, [:other_countries_os_saudi_arabia_local_resident_partner_not_irish, :other_countries_os_saudi_arabia_local_resident_partner_not_irish_two]
    end
  end
#testing for saudi arabia, local resident, partner other
  context "ceremony in saudi arabia, resident in saudi arabia, partner other" do
    setup do
      add_response 'saudi-arabia'
      add_response 'other'
      add_response 'saudi-arabia'
      add_response 'partner_other'
      add_response 'opposite_sex'
    end
    should "go to consular cni os outcome" do
      assert_current_node :outcome_os_other_countries
      assert_phrase_list :other_countries_os_outcome, [:other_countries_os_saudi_arabia_local_resident_partner_not_irish, :other_countries_os_saudi_arabia_local_resident_partner_not_irish_or_british, :other_countries_os_saudi_arabia_local_resident_partner_not_irish_two]
    end
  end

#testing for civil partnership in countries with CP or equivalent
#testing for ceremony in denmark, england resident, other partner
  context "ceremony in denmark, resident in england, partner other" do
    setup do
      add_response 'denmark'
      add_response 'uk'
      add_response 'uk_england'
      add_response 'partner_other'
      add_response 'same_sex'
    end
    should "go to cp or equivalent outcome" do
      assert_current_node :outcome_cp_cp_or_equivalent
      assert_phrase_list :cp_or_equivalent_cp_outcome, [:"cp_or_equivalent_cp_denmark", :cp_or_equivalent_cp_uk_resident, :cp_or_equivalent_cp_all_what_you_need_to_do, :cp_or_equivalent_cp_naturalisation, :cp_or_equivalent_all_depositing_certificate, :cp_or_equivalent_cp_uk_resident_two, :cp_or_equivalent_cp_all_fees, :cp_or_equivalent_cp_cash_or_credit_card_countries]
    end
  end
#testing for ceremony in czech republic, other resident, local partner
  context "ceremony in czech republic, resident in poland, partner local" do
    setup do
      add_response 'czech-republic'
      add_response 'other'
      add_response 'poland'
      add_response 'partner_local'
      add_response 'same_sex'
    end
    should "go to cp or equivalent outcome" do
      assert_current_node :outcome_cp_cp_or_equivalent
      assert_phrase_list :cp_or_equivalent_cp_outcome, [:cp_or_equivalent_cp_czech_republic_partner_local, :cp_or_equivalent_cp_other_resident, :cp_or_equivalent_cp_all_what_you_need_to_do, :cp_or_equivalent_cp_naturalisation, :cp_or_equivalent_all_depositing_certificate, :cp_or_equivalent_cp_all_fees, :cp_or_equivalent_cp_local_currency_countries]
    end
  end
#testing for ceremony in sweden, sweden resident, irish partner
  context "ceremony in sweden, resident in sweden, partner irish" do
    setup do
      add_response 'sweden'
      add_response 'other'
      add_response 'sweden'
      add_response 'partner_irish'
      add_response 'same_sex'
    end
    should "go to cp or equivalent os outcome" do
      assert_current_node :outcome_cp_cp_or_equivalent
      assert_phrase_list :cp_or_equivalent_cp_outcome, [:cp_or_equivalent_cp_sweden, :cp_or_equivalent_cp_local_resident, :cp_or_equivalent_cp_all_what_you_need_to_do, :cp_or_equivalent_cp_naturalisation, :cp_or_equivalent_all_depositing_certificate, :cp_or_equivalent_cp_all_fees, :cp_or_equivalent_cp_cash_or_credit_card_countries]
    end
  end
#testing for civil partnership in France, or french overseas territories  with PACS law
#testing for ceremony in france, england resident, other partner
  context "ceremony in france, resident in england, partner other" do
    setup do
      add_response 'france'
      add_response 'uk'
      add_response 'uk_england'
      add_response 'partner_other'
      add_response 'same_sex'
    end
    should "go to cp or equivalent outcome" do
      assert_current_node :outcome_cp_france_pacs
      assert_phrase_list :france_pacs_law_cp_outcome, [:france_pacs_law_cp_all_intro, :france_pacs_law_cp_ceremony_france_uk_resident, :france_pacs_law_cp_all_cp_what_you_need_to_do, :france_pacs_law_cp_uk_resident_two, :france_pacs_law_cp_all_celibacy_certificate, :france_pacs_law_cp_naturalisation, :france_pacs_law_cp_all_depositing_pacs_certificate, :france_pacs_law_cp_uk_resident_two_point_five, :france_pacs_law_all_pacs_extract, :france_pacs_law_cp_uk_resident_three, :france_pacs_law_cp_all_fees]
    end
  end
#testing for ceremony in france, other resident, local partner
  context "ceremony in france, resident in poland, partner local" do
    setup do
      add_response 'france'
      add_response 'other'
      add_response 'poland'
      add_response 'partner_local'
      add_response 'same_sex'
    end
    should "go to cp or equivalent outcome" do
      assert_current_node :outcome_cp_france_pacs
      assert_phrase_list :france_pacs_law_cp_outcome, [:france_pacs_law_cp_all_intro, :france_pacs_law_cp_ceremony_france_other_resident, :france_pacs_law_cp_all_cp_what_you_need_to_do, :france_pacs_law_cp_not_uk_resident_two, :france_pacs_law_cp_all_celibacy_certificate, :france_pacs_law_cp_naturalisation, :france_pacs_law_cp_all_depositing_pacs_certificate, :france_pacs_law_all_pacs_extract, :france_pacs_law_cp_all_fees]
    end
  end
#testing for ceremony in france, france resident, british partner
  context "ceremony in france, resident in france, partner british" do
    setup do
      add_response 'france'
      add_response 'other'
      add_response 'france'
      add_response 'partner_british'
      add_response 'same_sex'
    end
    should "go to cp or equivalent outcome" do
      assert_current_node :outcome_cp_france_pacs
      assert_phrase_list :france_pacs_law_cp_outcome, [:france_pacs_law_cp_all_intro, :france_pacs_law_cp_ceremony_france_local_resident, :france_pacs_law_cp_all_cp_what_you_need_to_do, :france_pacs_law_cp_not_uk_resident_two, :france_pacs_law_cp_all_celibacy_certificate, :france_pacs_law_cp_all_depositing_pacs_certificate, :france_pacs_law_all_pacs_extract, :france_pacs_law_cp_all_fees]
    end
  end
#testing for ceremony in new caledonia, other resident, local partner
  context "ceremony in new caledonia, resident in poland, partner local" do
    setup do
      add_response 'new-caledonia'
      add_response 'other'
      add_response 'poland'
      add_response 'partner_local'
      add_response 'same_sex'
    end
    should "go to cp or equivalent outcome" do
      assert_current_node :outcome_cp_france_pacs
      assert_phrase_list :france_pacs_law_cp_outcome, [:france_pacs_law_cp_all_intro, :france_pacs_law_cp_ceremony_nc_or_wf_cp_other_resident, :france_pacs_law_cp_all_cp_what_you_need_to_do, :france_pacs_law_cp_not_uk_resident_two, :france_pacs_law_cp_all_celibacy_certificate, :france_pacs_law_cp_naturalisation, :france_pacs_law_cp_all_depositing_pacs_certificate, :france_pacs_law_all_pacs_extract, :france_pacs_law_cp_all_fees]
    end
  end

#testing for CP in countries where cni not required
#testing for ceremony in united states, england resident, local partner
  context "ceremony in US, resident in ni, partner local" do
    setup do
      add_response 'united-states'
      add_response 'uk'
      add_response 'uk_ni'
      add_response 'partner_local'
      add_response 'same_sex'
    end
    should "go to cp no cni required outcome" do
      assert_current_node :outcome_cp_no_cni
      assert_phrase_list :no_cni_required_cp_outcome, [:"no_cni_required_cp_united-states", :no_cni_required_all_legal_advice, :no_cni_required_cp_ceremony_us, :no_cni_required_all_what_you_need_to_do, :no_cni_required_cp_not_dutch_islands_uk_resident, :no_cni_required_cp_all_consular_facilities, :no_cni_required_cp_all_depositing_certifictate, :no_cni_required_cp_ceremony_us_two, :no_cni_required_cp_uk_resident_three, :no_cni_required_cp_naturalisation, :no_cni_required_cp_all_fees]
    end
  end
#testing for ceremony in bonaire, england resident, other partner
  context "ceremony in bonaire, resident in scotland, partner other" do
    setup do
      add_response 'bonaire-st-eustatius-saba'
      add_response 'uk'
      add_response 'uk_scotland'
      add_response 'partner_other'
      add_response 'same_sex'
    end
    should "go to cp no cni required outcome" do
      assert_current_node :outcome_cp_no_cni
      assert_phrase_list :no_cni_required_cp_outcome, [:"no_cni_required_cp_bonaire-st-eustatius-saba", :no_cni_required_all_legal_advice, :no_cni_required_all_what_you_need_to_do, :no_cni_required_cp_dutch_islands, :no_cni_required_cp_dutch_islands_uk_resident, :no_cni_required_cp_all_consular_facilities, :no_cni_required_cp_all_depositing_certifictate, :no_cni_required_cp_ceremony_not_us, :no_cni_required_cp_uk_resident_three, :no_cni_required_cp_naturalisation, :no_cni_required_cp_all_fees]
    end
  end
#testing for ceremony in bonaire, bonaire resident, british partner
  context "ceremony in bonaire, resident in bonaire, partner british" do
    setup do
      add_response 'bonaire-st-eustatius-saba'
      add_response 'other'
      add_response 'bonaire-st-eustatius-saba'
      add_response 'partner_british'
      add_response 'same_sex'
    end
    should "go to cp no cni required outcome" do
      assert_current_node :outcome_cp_no_cni
      assert_phrase_list :no_cni_required_cp_outcome, [:"no_cni_required_cp_bonaire-st-eustatius-saba", :no_cni_required_all_legal_advice, :no_cni_required_all_what_you_need_to_do, :no_cni_required_cp_dutch_islands, :no_cni_required_cp_dutch_islands_local_resident, :no_cni_required_cp_all_consular_facilities, :no_cni_required_cp_all_depositing_certifictate, :no_cni_required_cp_ceremony_not_us, :no_cni_required_cp_all_fees]
    end
  end
#testing for ceremony in bonaire, other resident, irish partner
  context "ceremony in US, resident in mexico, partner other" do
    setup do
      add_response 'bonaire-st-eustatius-saba'
      add_response 'other'
      add_response 'mexico'
      add_response 'partner_irish'
      add_response 'same_sex'
    end
    should "go to cp no cni required outcome" do
      assert_current_node :outcome_cp_no_cni
      assert_phrase_list :no_cni_required_cp_outcome, [:"no_cni_required_cp_bonaire-st-eustatius-saba", :no_cni_required_all_legal_advice, :no_cni_required_all_what_you_need_to_do, :no_cni_required_cp_dutch_islands, :no_cni_required_cp_dutch_islands_other_resident, :no_cni_required_cp_all_consular_facilities, :no_cni_required_cp_all_depositing_certifictate, :no_cni_required_cp_ceremony_not_us, :no_cni_required_cp_naturalisation, :no_cni_required_cp_all_fees]
    end
  end

#testing for CP in commonwealth countries outcomes
#testing for ceremony in australia, uk resident, irish partner
  context "ceremony in australia, resident in wales, partner irish" do
    setup do
      add_response 'australia'
      add_response 'uk'
      add_response 'uk_wales'
      add_response 'partner_irish'
      add_response 'same_sex'
    end
    should "go to cp commonwealth countries outcome" do
      assert_current_node :outcome_cp_commonwealth_countries
      assert_phrase_list :commonwealth_countries_cp_outcome, [:commonwealth_countries_cp_australia, :commonwealth_countries_cp_australia_two, :commonwealth_countries_cp_uk_resident_two, :commonwealth_countries_cp_australia_three, :commonwealth_countries_cp_australia_four, :commonwealth_countries_cp_australia_five, :commonwealth_countries_cp_all_depositing_cp_certificate, :commonwealth_countries_cp_uk_resident_three, :commonwealth_countries_cp_naturalisation, :commonwealth_countries_cp_australia_six]
    end
  end
#testing for ceremony in australia, australia resident, british partner
  context "ceremony in australia, resident in australia, partner british" do
    setup do
      add_response 'australia'
      add_response 'other'
      add_response 'australia'
      add_response 'partner_british'
      add_response 'same_sex'
    end
    should "go to cp commonwealth countries outcome" do
      assert_current_node :outcome_cp_commonwealth_countries
      assert_phrase_list :commonwealth_countries_cp_outcome, [:commonwealth_countries_cp_australia, :commonwealth_countries_cp_australia_two, :commonwealth_countries_cp_local_resident, :commonwealth_countries_cp_australia_three, :commonwealth_countries_cp_australia_four, :commonwealth_countries_cp_australia_five, :commonwealth_countries_cp_all_depositing_cp_certificate, :commonwealth_countries_cp_australia_six]
    end
  end
#testing for ceremony in australia, other resident, local partner
  context "ceremony in australia, other resident, partner local" do
    setup do
      add_response 'australia'
      add_response 'other'
      add_response 'canada'
      add_response 'partner_local'
      add_response 'same_sex'
    end
    should "go to cp commonwealth countries outcome" do
      assert_current_node :outcome_cp_commonwealth_countries
      assert_phrase_list :commonwealth_countries_cp_outcome, [:commonwealth_countries_cp_australia, :commonwealth_countries_cp_australia_two, :commonwealth_countries_cp_other_resident, :commonwealth_countries_cp_australia_three, :commonwealth_countries_cp_australia_four, :commonwealth_countries_cp_australia_partner_local, :commonwealth_countries_cp_australia_five, :commonwealth_countries_cp_all_depositing_cp_certificate, :commonwealth_countries_cp_naturalisation, :commonwealth_countries_cp_australia_six]
    end
  end
#testing for ceremony in canada, uk resident, other partner
  context "ceremony in canada, uk resident, partner other" do
    setup do
      add_response 'canada'
      add_response 'uk'
      add_response 'uk_ci'
      add_response 'partner_other'
      add_response 'same_sex'
    end
    should "go to cp commonwealth countries outcome" do
      assert_current_node :outcome_cp_commonwealth_countries
      assert_phrase_list :commonwealth_countries_cp_outcome, [:commonwealth_countries_cp_canada, :commonwealth_countries_cp_uk_resident_two, :commonwealth_countries_cp_all_depositing_cp_certificate, :commonwealth_countries_cp_ceremony_not_australia, :commonwealth_countries_cp_uk_resident_three, :commonwealth_countries_cp_naturalisation]
    end
  end

#testing for CP in countries with consular cni (not australia)
# testing for czech republic with non-local partner
  context "ceremony in czech-republic, uk resident, partner other" do
    setup do
      add_response 'czech-republic'
      add_response 'uk'
      add_response 'uk_ci'
      add_response 'partner_other'
      add_response 'same_sex'
    end
    should "go to consular cni cp countries outcome" do
      assert_current_node :outcome_cp_consular_cni
      assert_phrase_list :consular_cni_cp_outcome, [:consular_cni_cp_ceremony_czech_republic_partner_not_local, :consular_cni_cp_all_contact, :consular_cni_cp_all_documents, :consular_cni_cp_partner_not_british, :consular_cni_cp_all_what_you_need_to_do, :consular_cni_cp_naturalisation, :consular_cni_cp_all_fees, :consular_cni_cp_cheque]
    end
  end
# testing for vietnam with local partner
  context "ceremony in vietnam, uk resident, partner local" do
    setup do
      add_response 'vietnam'
      add_response 'uk'
      add_response 'uk_ci'
      add_response 'partner_local'
      add_response 'same_sex'
    end
    should "go to consular cni cp countries outcome" do
      assert_current_node :outcome_cp_consular_cni
      assert_phrase_list :consular_cni_cp_outcome, [:consular_cni_cp_ceremony_not_czech_republic, :consular_cni_cp_ceremony_vietnam_partner_local]
    end
  end
# testing for latvia, other resident, british partner
  context "ceremony in latvia, cyprus resident, partner british" do
    setup do
      add_response 'latvia'
      add_response 'other'
      add_response 'cyprus'
      add_response 'partner_british'
      add_response 'same_sex'
    end
    should "go to consular cni cp countries outcome" do
      assert_current_node :outcome_cp_consular_cni
      assert_phrase_list :consular_cni_cp_outcome, [:consular_cni_cp_ceremony_not_czech_republic, :consular_cni_cp_all_contact, :consular_cni_cp_all_documents, :consular_cni_cp_all_what_you_need_to_do, :consular_cni_cp_all_fees, :consular_cni_cp_local_currency]
    end
  end

#testing for other countries outcome
# testing for serbia, other resident, british partner
  context "ceremony in serbia, cyprus resident, partner british" do
    setup do
      add_response 'serbia'
      add_response 'other'
      add_response 'cyprus'
      add_response 'partner_british'
      add_response 'same_sex'
    end
    should "go to cp all other countries outcome" do
      assert_current_node :outcome_cp_all_other_countries
    end
  end
end
