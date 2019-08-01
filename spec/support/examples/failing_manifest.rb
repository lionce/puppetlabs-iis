shared_examples 'a failing manifest' do |manifest|
  execute_manifest(manifest, expect_failures: true)
end
