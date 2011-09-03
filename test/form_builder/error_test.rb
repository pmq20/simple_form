require 'test_helper'

# Tests for f.error and f.full_error
class ErrorTest < ActionView::TestCase
  def with_error_for(object, *args)
    with_concat_form_for(object) do |f|
      f.error(*args)
    end
  end

  def with_full_error_for(object, *args)
    with_concat_form_for(object) do |f|
      f.full_error(*args)
    end
  end

  test 'error should not generate content for attribute without errors' do
    with_error_for @user, :active
    assert_no_select 'span.error'
  end

  test 'error should not generate messages when object is not present' do
    with_error_for :project, :name
    assert_no_select 'span.error'
  end

  test "error should not generate messages when object doesn't respond to errors method" do
    @user.instance_eval { undef errors }
    with_error_for @user, :name
    assert_no_select 'span.error'
  end

  test 'error should generate messages for attribute with single error' do
    with_error_for @user, :name
    assert_select 'span.error', "can't be blank"
  end

  test 'error should generate messages for attribute with one error when using first' do
    swap SimpleForm, :error_method => :first do
      with_error_for @user, :age
      assert_select 'span.error', 'is not a number'
    end
  end

  test 'error should generate messages for attribute with several errors when using to_sentence' do
    swap SimpleForm, :error_method => :to_sentence do
      with_error_for @user, :age
      assert_select 'span.error', 'is not a number and must be greater than 18'
    end
  end

  test 'error should be able to pass html options' do
    with_error_for @user, :name, :id => 'error', :class => 'yay'
    assert_select 'span#error.error.yay'
  end

  test 'error should find errors on attribute and association' do
    with_error_for @user, :company_id, :as => :select,
      :error_method => :to_sentence, :reflection => Association.new(Company, :company, {})
    assert_select 'span.error', 'must be valid and company must be present'
  end

  test 'error should generate an error tag with a clean HTML' do
    with_error_for @user, :name
    assert_no_select 'span.error[error_html]'
  end

  test 'error should generate an error tag with a clean HTML when errors options are present' do
    with_error_for @user, :name, :error_tag => :p, :error_prefix => 'Name', :error_method => :first
    assert_no_select 'p.error[error_html]'
    assert_no_select 'p.error[error_tag]'
    assert_no_select 'p.error[error_prefix]'
    assert_no_select 'p.error[error_method]'
  end

  # FULL ERRORS

  test 'builder should generate an full error tag for the attribute' do
    with_full_error_for @user, :name
    assert_select 'span.error', "Super User Name! can't be blank"
  end

  test 'builder should generate an full  error tag with a clean HTML' do
    with_full_error_for @user, :name
    assert_no_select 'span.error[error_html]'
  end

  test 'builder should allow passing options to full error tag' do
    with_full_error_for @user, :name, :id => 'name_error', :error_prefix => "Your name"
    assert_select 'span.error#name_error', "Your name can't be blank"
  end
end
