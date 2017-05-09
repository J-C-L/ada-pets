require 'test_helper'

class PetsControllerTest < ActionDispatch::IntegrationTest
  describe "index" do
    # These tests are a little verbose - yours do not need to be
    # this explicit.
    it "is a real working route" do
      get pets_url
      must_respond_with :success
    end

    it "returns json" do
      get pets_url
      response.header['Content-Type'].must_include 'json'
    end

    it "returns an Array" do
      get pets_url

      body = JSON.parse(response.body)
      body.must_be_kind_of Array
    end

    it "returns all of the pets" do
      get pets_url

      body = JSON.parse(response.body)
      body.length.must_equal Pet.count
    end

    it "returns pets with exactly the required fields" do
      keys = %w(age human id name)
      get pets_url
      body = JSON.parse(response.body)
      body.each do |pet|
        pet.keys.sort.must_equal keys
      end
    end
  end

  describe "show" do
    it "can get a pet that exists" do
      get pet_path(pets(:two).id)
      must_respond_with :success

      body = JSON.parse(response.body)
      body["name"].must_equal "Horsetooth"
    end

    it "returns json" do
      get pet_path(pets(:two).id)
      response.header['Content-Type'].must_include 'json'
    end


    it "gives an approriate error message and status not found for a pet that does not exist" do
      id= Pet.last.id + 1
      get pet_path(id)
      must_respond_with :not_found
      # OR
      # must_respond_with 404

      body = JSON.parse(response.body)
      # body.values.must_include "Could not find a pet with id #{id}"
      # OR
      errors_hash = { "errors" => "Could not find a pet with id #{id}"}
      body.must_equal errors_hash
    end
  end

  describe "create" do
    let(:pet_data) {
      {
        name: "Jack",
        age: 7,
        human: "Captain Barbossa"
      }
    }

    it "Creates a new pet" do

      #THESE ARE ASSERT STYLE TESTING, BUT THEY GIVE A SENSE OF WHAT TO TEST

      # ALSO TEST THAT THE ID IS INCLUDED IN THE JSON RETURNED
      
      assert_difference "Pet.count", 1 do
        post pets_url, params: { pet: pet_data }
        assert_response :success
      end

      body = JSON.parse(response.body)
      body.must_be_kind_of Hash
      body.must_include "id"

      # Check that the ID matches
      Pet.find(body["id"]).name.must_equal pet_data[:name]
    end

    it "Returns an error for an invalid pet" do
      bad_data = pet_data.clone()
      bad_data.delete(:name)
      assert_no_difference "Pet.count" do
        post pets_url, params: { pet: bad_data }
        assert_response :bad_request
      end

      body = JSON.parse(response.body)
      body.must_be_kind_of Hash
      body.must_include "errors"
      body["errors"].must_include "name"
    end
  end
end
