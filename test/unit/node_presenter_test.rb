# coding:utf-8

require_relative '../test_helper'
require 'ostruct'

module SmartAnswer
  class NodePresenterTest < ActiveSupport::TestCase
    def setup
      @old_load_path = I18n.config.load_path.dup
      @example_translation_file = 
        File.expand_path('../../fixtures/node_presenter_test/example.yml', __FILE__)
      I18n.config.load_path.unshift(@example_translation_file)
      I18n.reload!
    end
    
    def teardown
      I18n.config.load_path = @old_load_path
      I18n.reload!
    end
  
    test "Node title looked up from translation file" do
      question = Question::Date.new(:example_question?)
      presenter = NodePresenter.new("flow.test", question)
      
      assert_equal 'Foo', presenter.title
    end

    test "Node title can be interpolated with state" do
      question = Question::Date.new(:interpolated_question)
      state = State.new(question.name)
      state.day = 'Monday'
      presenter = NodePresenter.new("flow.test", question, state)

      assert_equal 'Is today a Monday?', presenter.title
      assert_match /Today is Monday/, presenter.body
    end    

    test "Interpolated dates are localized" do
      question = Question::Date.new(:interpolated_question)
      state = State.new(question.name)
      state.day = Date.parse('2011-04-05')
      presenter = NodePresenter.new("flow.test", question, state)
      
      assert_match /Today is  5 April 2011/, presenter.body
    end
    
    test "Node body looked up from translation file, rendered using govspeak" do
      question = Question::Date.new(:example_question?)
      presenter = NodePresenter.new("flow.test", question)
      
      assert_equal "<p>The body copy</p>\n", presenter.body
    end
    
    test "Can check if a node has body" do
      assert NodePresenter.new("flow.test", Question::Date.new(:example_question?)).has_body?, "example_question? has body"
      assert ! NodePresenter.new("flow.test", Question::Date.new(:missing)).has_body?, "missing has no body"
    end
    
    test "Node subtitle looked up" do
      presenter = NodePresenter.new("flow.test", Question::Date.new(:example_question?))
      assert_equal 'This is the subtitle', presenter.subtitle
    end
    
    test "Can check if a node has subtitle" do
      assert NodePresenter.new("flow.test", Question::Date.new(:example_question?)).has_subtitle?
      assert ! NodePresenter.new("flow.test", Question::Date.new(:missing)).has_subtitle?
    end
    
    test "Options can be looked up from translation file" do
      question = Question::MultipleChoice.new(:example_question?)
      question.option yes: :yay
      question.option no: :nay
      presenter = NodePresenter.new("flow.test", question)
      
      assert_equal "Oui", presenter.options[0].label
      assert_equal "Non", presenter.options[1].label
      assert_equal "yes", presenter.options[0].value
      assert_equal "no", presenter.options[1].value
    end
    
    test "Options can be looked up from default values in translation file" do
      question = Question::MultipleChoice.new(:example_question?)
      question.option maybe: :mumble
      presenter = NodePresenter.new("flow.test", question)
      
      assert_equal "Mebbe", presenter.options[0].label
    end
    
    test "Options label falls back to option value" do
      question = Question::MultipleChoice.new(:example_question?)
      question.option something: :mumble
      presenter = NodePresenter.new("flow.test", question)
      
      assert_equal "something", presenter.options[0].label
    end
    
    test "Can lookup a response label for a multiple choice question" do
      question = Question::MultipleChoice.new(:example_question?)
      question.option yes: :yay
      question.option no: :nay
      presenter = MultipleChoiceQuestionPresenter.new("flow.test", question)
      
      assert_equal "Oui", presenter.response_label("yes")
    end

    test "Can lookup a response label for a date question" do
      question = Question::Date.new(:example_question?)
      presenter = DateQuestionPresenter.new("flow.test", question)
      
      assert_equal " 1 March 2011", presenter.response_label("2011-03-01")
    end

  end
end