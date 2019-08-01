shared_examples 'with a puppet resource run' do |_type, _name, result|
  it 'returns successfully' do
    expect(result.exit_code).to eq 0
  end

  it 'does not return an error' do
    expect(result.stderr).not_to match(%r{\b})
  end
end
