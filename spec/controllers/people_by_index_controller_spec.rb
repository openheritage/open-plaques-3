require 'spec_helper'

describe PeopleByIndexController do
  let!(:a_person) do
    Person.create!(
      name: 'Aardvark',
      surname_starts_with: 'a',
      personal_connections_count: 1
    )
  end
  let!(:a_person_no_plaques) do
    Person.create!(
      name: 'Arry',
      surname_starts_with: 'a',
      personal_connections_count: 0
    )
  end
  let!(:b_person) do
    Person.create!(
      name: 'Barry',
      surname_starts_with: 'b',
      personal_connections_count: 1
    )
  end

  describe '#show' do
    context 'with uppercase index letter' do
      before { get :show, params: { id: 'A' } }
      it 'should redirect' do
        expect(response).to redirect_to(people_by_index_path('a'))
      end
    end
    context 'with lowercase index letter' do
      before { get :show, params: { id: 'a' } }
      it 'should return 200' do
        expect(response).to be_success
      end
      it 'should assign to @people' do
        expect(assigns(:people)).to eql([a_person])
      end
    end
  end
end
