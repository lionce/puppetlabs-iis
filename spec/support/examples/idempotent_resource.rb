shared_examples 'an idempotent resource' do |manifest|
  execute_manifest(manifest, catch_failures: true)
  execute_manifest(manifest, catch_changes: true)
end
