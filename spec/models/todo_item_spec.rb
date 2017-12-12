describe TodoItem, type: :model do
  it 'has a valid factory' do
    expect(create(:todo_item)).to be_valid
  end
end
