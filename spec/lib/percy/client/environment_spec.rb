RSpec.describe Percy::Client::Environment do
  def clear_env_vars
    # Unset Percy vars.
    ENV['PERCY_COMMIT'] = nil
    ENV['PERCY_BRANCH'] = nil
    ENV['PERCY_TARGET_BRANCH'] = nil
    ENV['PERCY_PULL_REQUEST'] = nil
    ENV['PERCY_PROJECT'] = nil
    ENV['PERCY_REPO_SLUG'] = nil # Deprecated.
    ENV['PERCY_PARALLEL_NONCE'] = nil
    ENV['PERCY_PARALLEL_TOTAL'] = nil

    # Unset Travis vars.
    ENV['TRAVIS_BUILD_ID'] = nil
    ENV['TRAVIS_BUILD_NUMBER'] = nil
    ENV['TRAVIS_COMMIT'] = nil
    ENV['TRAVIS_BRANCH'] = nil
    ENV['TRAVIS_PULL_REQUEST'] = nil
    ENV['TRAVIS_PULL_REQUEST_BRANCH'] = nil
    ENV['TRAVIS_PULL_REQUEST_SHA'] = nil
    ENV['TRAVIS_REPO_SLUG'] = nil
    ENV['CI_NODE_TOTAL'] = nil

    # Unset Jenkins vars.
    ENV['JENKINS_URL'] = nil
    ENV['ghprbPullId'] = nil
    ENV['ghprbActualCommit'] = nil
    ENV['ghprbTargetBranch'] = nil

    # Unset Circle CI vars.
    ENV['CIRCLECI'] = nil
    ENV['CIRCLE_SHA1'] = nil
    ENV['CIRCLE_BRANCH'] = nil
    ENV['CIRCLE_PROJECT_USERNAME'] = nil
    ENV['CIRCLE_PROJECT_REPONAME'] = nil
    ENV['CIRCLE_BUILD_NUM'] = nil
    ENV['CI_PULL_REQUESTS'] = nil

    # Unset Codeship vars.
    ENV['CI_NAME'] = nil
    ENV['CI_BRANCH'] = nil
    ENV['CI_PULL_REQUEST'] = nil
    ENV['CI_COMMIT_ID'] = nil
    ENV['CI_BUILD_NUMBER'] = nil
    ENV['CI_NODE_TOTAL'] = nil

    # Unset Drone vars.
    ENV['CI'] = nil
    ENV['DRONE'] = nil
    ENV['DRONE_COMMIT'] = nil
    ENV['DRONE_BRANCH'] = nil
    ENV['CI_PULL_REQUEST'] = nil

    # Unset Semaphore CI vars.
    ENV['CI'] = nil
    ENV['SEMAPHORE'] = nil
    ENV['REVISION'] = nil
    ENV['BRANCH_NAME'] = nil
    ENV['SEMAPHORE_REPO_SLUG'] = nil
    ENV['SEMAPHORE_BUILD_NUMBER'] = nil
    ENV['SEMAPHORE_CURRENT_THREAD'] = nil
    ENV['PULL_REQUEST_NUMBER'] = nil

    # Unset Buildkite CI vars.
    ENV['BUILDKITE'] = nil
    ENV['BUILDKITE_COMMIT'] = nil
    ENV['BUILDKITE_BRANCH'] = nil
    ENV['BUILDKITE_PULL_REQUEST'] = nil
    ENV['BUILDKITE_BUILD_ID'] = nil

    # Unset Gitlab CI vars.
    ENV['GITLAB_CI'] = nil
    ENV['CI_BUILD_REF'] = nil
    ENV['CI_BUILD_REF_NAME'] = nil
    ENV['CI_BUILD_ID'] = nil
  end

  before(:each) do
    @original_env = {
      'TRAVIS_BUILD_ID' => ENV['TRAVIS_BUILD_ID'],
      'TRAVIS_BUILD_NUMBER' => ENV['TRAVIS_BUILD_NUMBER'],
      'TRAVIS_COMMIT' => ENV['TRAVIS_COMMIT'],
      'TRAVIS_BRANCH' => ENV['TRAVIS_BRANCH'],
      'TRAVIS_PULL_REQUEST' => ENV['TRAVIS_PULL_REQUEST'],
      'TRAVIS_PULL_REQUEST_BRANCH' => ENV['TRAVIS_PULL_REQUEST_BRANCH'],
      'TRAVIS_PULL_REQUEST_SHA' => ENV['TRAVIS_PULL_REQUEST_SHA'],
      'TRAVIS_REPO_SLUG' => ENV['TRAVIS_REPO_SLUG'],
    }
    clear_env_vars
  end
  after(:each) do
    clear_env_vars
    ENV['TRAVIS_BUILD_ID'] = @original_env['TRAVIS_BUILD_ID']
    ENV['TRAVIS_BUILD_NUMBER'] = @original_env['TRAVIS_BUILD_NUMBER']
    ENV['TRAVIS_COMMIT'] = @original_env['TRAVIS_COMMIT']
    ENV['TRAVIS_BRANCH'] = @original_env['TRAVIS_BRANCH']
    ENV['TRAVIS_PULL_REQUEST'] = @original_env['TRAVIS_PULL_REQUEST']
    ENV['TRAVIS_PULL_REQUEST_BRANCH'] = @original_env['TRAVIS_PULL_REQUEST_BRANCH']
    ENV['TRAVIS_PULL_REQUEST_SHA'] = @original_env['TRAVIS_PULL_REQUEST_SHA']
    ENV['TRAVIS_REPO_SLUG'] = @original_env['TRAVIS_REPO_SLUG']
  end

  context 'no known CI environment' do
    describe '#current_ci' do
      it 'is nil' do
        expect(Percy::Client::Environment.current_ci).to be_nil
      end
    end
    describe '#branch' do
      it 'returns master if not in a git repo' do
        expect(Percy::Client::Environment).to receive(:_raw_branch_output).and_return('')
        expect(Percy::Client::Environment.branch).to eq('master')
      end
      it 'reads from the current local repo' do
        expect(Percy::Client::Environment.branch).to_not be_empty
      end
      it 'can be overridden with PERCY_BRANCH' do
        ENV['PERCY_BRANCH'] = 'test-branch'
        expect(Percy::Client::Environment.branch).to eq('test-branch')
      end
    end
    describe '#target_branch' do
      it 'returns nil if unset' do
        expect(Percy::Client::Environment.target_branch).to be_nil
      end
      it 'can be set with PERCY_TARGET_BRANCH' do
        ENV['PERCY_TARGET_BRANCH'] = 'test-target-branch'
        expect(Percy::Client::Environment.target_branch).to eq('test-target-branch')
      end
    end
    describe '#_commit_sha' do
      it 'returns nil if no environment info can be found' do
        expect(Percy::Client::Environment._commit_sha).to be_nil
      end
      it 'can be overridden with PERCY_COMMIT' do
        ENV['PERCY_COMMIT'] = 'test-commit'
        expect(Percy::Client::Environment._commit_sha).to eq('test-commit')
      end
    end
    describe '#pull_request_number' do
      it 'returns nil if no CI environment' do
        expect(Percy::Client::Environment.pull_request_number).to be_nil
      end
      it 'can be overridden with PERCY_PULL_REQUEST' do
        ENV['PERCY_PULL_REQUEST'] = '123'
        ENV['TRAVIS_BUILD_ID'] = '1234'
        ENV['TRAVIS_PULL_REQUEST'] = '256'
        expect(Percy::Client::Environment.pull_request_number).to eq('123')
      end
    end
    describe '#repo' do
      it 'returns the current local repo name' do
        expect(Percy::Client::Environment.repo).to eq('percy/percy-client')
      end
      it 'can be overridden with PERCY_PROJECT' do
        ENV['PERCY_PROJECT'] = 'percy/slug'
        expect(Percy::Client::Environment.repo).to eq('percy/slug')
      end
      it 'can be overridden with PERCY_REPO_SLUG (deprecated)' do
        ENV['PERCY_REPO_SLUG'] = 'percy/slug'
        expect(Percy::Client::Environment.repo).to eq('percy/slug')
      end
      it 'handles git ssh urls' do
        expect(Percy::Client::Environment).to receive(:_get_origin_url)
          .once.and_return('git@github.com:org-name/repo-name.git')
        expect(Percy::Client::Environment.repo).to eq('org-name/repo-name')

        expect(Percy::Client::Environment).to receive(:_get_origin_url)
          .once.and_return('git@github.com:org-name/repo-name.org.git')
        expect(Percy::Client::Environment.repo).to eq('org-name/repo-name.org')

        expect(Percy::Client::Environment).to receive(:_get_origin_url)
          .once.and_return('git@custom-local-hostname:org-name/repo-name.org')
        expect(Percy::Client::Environment.repo).to eq('org-name/repo-name.org')
      end
      it 'handles git https urls' do
        expect(Percy::Client::Environment).to receive(:_get_origin_url)
          .once.and_return('https://github.com/org-name/repo-name.git')
        expect(Percy::Client::Environment.repo).to eq('org-name/repo-name')

        expect(Percy::Client::Environment).to receive(:_get_origin_url)
          .once.and_return('https://github.com/org-name/repo-name.org.git')
        expect(Percy::Client::Environment.repo).to eq('org-name/repo-name.org')

        expect(Percy::Client::Environment).to receive(:_get_origin_url)
          .once.and_return("https://github.com/org-name/repo-name.org\n")
        expect(Percy::Client::Environment.repo).to eq('org-name/repo-name.org')
      end
      it 'errors if unable to parse local repo name' do
        expect(Percy::Client::Environment).to receive(:_get_origin_url).once.and_return('foo')
        expect { Percy::Client::Environment.repo }.to raise_error(
          Percy::Client::Environment::RepoNotFoundError,
        )
      end
    end
    describe '#parallel_nonce' do
      it 'returns nil' do
        expect(Percy::Client::Environment.parallel_nonce).to be_nil
      end
      it 'can be set with environment var' do
        ENV['PERCY_PARALLEL_NONCE'] = 'nonce'
        expect(Percy::Client::Environment.parallel_nonce).to eq('nonce')
      end
    end
    describe '#parallel_total_shards' do
      it 'returns nil' do
        expect(Percy::Client::Environment.parallel_nonce).to be_nil
      end
      it 'can be set with environment var' do
        ENV['PERCY_PARALLEL_TOTAL'] = '3'
        expect(Percy::Client::Environment.parallel_total_shards).to eq(3)
      end
    end
  end
  context 'in Jenkins CI' do
    before(:each) do
      ENV['JENKINS_URL'] = 'http://localhost:8080/'
      ENV['ghprbPullId'] = '123'
      ENV['ghprbTargetBranch'] = 'jenkins-target-branch'
      ENV['ghprbActualCommit'] = 'jenkins-actual-commit'
    end

    it 'has the correct properties' do
      expect(Percy::Client::Environment.current_ci).to eq(:jenkins)
      expect(Percy::Client::Environment.branch).to eq('jenkins-target-branch')
      expect(Percy::Client::Environment._commit_sha).to eq('jenkins-actual-commit')
      expect(Percy::Client::Environment.pull_request_number).to eq('123')
      expect(Percy::Client::Environment.repo).to eq('percy/percy-client')
    end
  end
  context 'in Travis CI' do
    before(:each) do
      ENV['TRAVIS_BUILD_ID'] = '1234'
      ENV['TRAVIS_BUILD_NUMBER'] = 'build-number'
      ENV['TRAVIS_PULL_REQUEST'] = 'false'
      ENV['TRAVIS_PULL_REQUEST_BRANCH'] = ''
      ENV['TRAVIS_PULL_REQUEST_SHA'] = ''
      ENV['TRAVIS_REPO_SLUG'] = 'travis/repo-slug'
      ENV['TRAVIS_COMMIT'] = 'travis-commit-sha'
      ENV['TRAVIS_BRANCH'] = 'travis-branch'
      ENV['CI_NODE_TOTAL'] = ''
    end

    it 'has the correct properties' do
      expect(Percy::Client::Environment.current_ci).to eq(:travis)
      expect(Percy::Client::Environment.branch).to eq('travis-branch')
      expect(Percy::Client::Environment._commit_sha).to eq('travis-commit-sha')
      expect(Percy::Client::Environment.pull_request_number).to be_nil
      expect(Percy::Client::Environment.repo).to eq('travis/repo-slug')
      expect(Percy::Client::Environment.parallel_nonce).to eq('build-number')
      expect(Percy::Client::Environment.parallel_total_shards).to be_nil
    end
    context 'Pull Request build' do
      before(:each) do
        ENV['TRAVIS_PULL_REQUEST'] = '256'
        ENV['TRAVIS_PULL_REQUEST_BRANCH'] = 'travis-pr-branch'
        ENV['TRAVIS_PULL_REQUEST_SHA'] = 'travis-pr-head-commit-sha'
      end
      it 'has the correct properties' do
        expect(Percy::Client::Environment.branch).to eq('travis-pr-branch')
        expect(Percy::Client::Environment._commit_sha).to eq('travis-pr-head-commit-sha')
        expect(Percy::Client::Environment.pull_request_number).to eq('256')
      end
    end
    context 'parallel build' do
      before(:each) do
        ENV['CI_NODE_TOTAL'] = '3'
      end
      it 'has the correct properties' do
        expect(Percy::Client::Environment.parallel_nonce).to eq('build-number')
        expect(Percy::Client::Environment.parallel_total_shards).to eq(3)
      end
    end
  end
  context 'in Circle CI' do
    before(:each) do
      ENV['CIRCLECI'] = 'true'
      ENV['CIRCLE_BRANCH'] = 'circle-branch'
      ENV['CIRCLE_SHA1'] = 'circle-commit-sha'
      ENV['CIRCLE_PROJECT_USERNAME'] = 'circle'
      ENV['CIRCLE_PROJECT_REPONAME'] = 'repo-name'
      ENV['CIRCLE_BUILD_NUM'] = 'build-number'
      ENV['CIRCLE_NODE_TOTAL'] = ''
      ENV['CI_PULL_REQUESTS'] = 'https://github.com/owner/repo-name/pull/123'
    end

    it 'has the correct properties' do
      expect(Percy::Client::Environment.current_ci).to eq(:circle)
      expect(Percy::Client::Environment.branch).to eq('circle-branch')
      expect(Percy::Client::Environment._commit_sha).to eq('circle-commit-sha')
      expect(Percy::Client::Environment.pull_request_number).to eq('123')
      expect(Percy::Client::Environment.repo).to eq('circle/repo-name')
      expect(Percy::Client::Environment.parallel_nonce).to eq('build-number')
      expect(Percy::Client::Environment.parallel_total_shards).to be_nil
    end
    context 'parallel build' do
      before(:each) do
        ENV['CIRCLE_NODE_TOTAL'] = '3'
      end
      it 'has the correct properties' do
        expect(Percy::Client::Environment.parallel_nonce).to eq('build-number')
        expect(Percy::Client::Environment.parallel_total_shards).to eq(3)
      end
    end
  end
  context 'in Codeship' do
    before(:each) do
      ENV['CI_NAME'] = 'codeship'
      ENV['CI_BRANCH'] = 'codeship-branch'
      ENV['CI_BUILD_NUMBER'] = 'codeship-build-number'
      ENV['CI_PULL_REQUEST'] = 'false' # This is always false on Codeship, unfortunately.
      ENV['CI_COMMIT_ID'] = 'codeship-commit-sha'
      ENV['CI_NODE_TOTAL'] = ''
    end

    it 'has the correct properties' do
      expect(Percy::Client::Environment.current_ci).to eq(:codeship)
      expect(Percy::Client::Environment.branch).to eq('codeship-branch')
      expect(Percy::Client::Environment._commit_sha).to eq('codeship-commit-sha')
      expect(Percy::Client::Environment.pull_request_number).to be_nil
      expect(Percy::Client::Environment.repo).to eq('percy/percy-client')
      expect(Percy::Client::Environment.parallel_nonce).to eq('codeship-build-number')
      expect(Percy::Client::Environment.parallel_total_shards).to be_nil
    end
    context 'parallel build' do
      before(:each) do
        ENV['CI_NODE_TOTAL'] = '3'
      end
      it 'has the correct properties' do
        expect(Percy::Client::Environment.parallel_nonce).to eq('codeship-build-number')
        expect(Percy::Client::Environment.parallel_total_shards).to eq(3)
      end
    end
  end
  context 'in Drone' do
    before(:each) do
      ENV['DRONE'] = 'true'
      ENV['DRONE_COMMIT'] = 'drone-commit-sha'
      ENV['DRONE_BRANCH'] = 'drone-branch'
      ENV['CI_PULL_REQUEST'] = '123'
    end

    it 'has the correct properties' do
      expect(Percy::Client::Environment.current_ci).to eq(:drone)
      expect(Percy::Client::Environment.branch).to eq('drone-branch')
      expect(Percy::Client::Environment._commit_sha).to eq('drone-commit-sha')
      expect(Percy::Client::Environment.pull_request_number).to eq('123')
      expect(Percy::Client::Environment.repo).to eq('percy/percy-client')
    end
  end
  context 'in Semaphore CI' do
    before(:each) do
      ENV['SEMAPHORE'] = 'true'
      ENV['BRANCH_NAME'] = 'semaphore-branch'
      ENV['REVISION'] = 'semaphore-commit-sha'
      ENV['SEMAPHORE_REPO_SLUG'] = 'repo-owner/repo-name'
      ENV['SEMAPHORE_BUILD_NUMBER'] = 'semaphore-build-number'
      ENV['SEMAPHORE_THREAD_COUNT'] = ''
      ENV['PULL_REQUEST_NUMBER'] = '123'
    end

    it 'has the correct properties' do
      expect(Percy::Client::Environment.current_ci).to eq(:semaphore)
      expect(Percy::Client::Environment.branch).to eq('semaphore-branch')
      expect(Percy::Client::Environment._commit_sha).to eq('semaphore-commit-sha')
      expect(Percy::Client::Environment.pull_request_number).to eq('123')
      expect(Percy::Client::Environment.repo).to eq('repo-owner/repo-name')
      expect(Percy::Client::Environment.parallel_nonce).to eq('semaphore-build-number')
      expect(Percy::Client::Environment.parallel_total_shards).to be_nil
    end
    context 'parallel build' do
      before(:each) do
        ENV['SEMAPHORE_THREAD_COUNT'] = '3'
      end
      it 'has the correct properties' do
        expect(Percy::Client::Environment.parallel_nonce).to eq('semaphore-build-number')
        expect(Percy::Client::Environment.parallel_total_shards).to eq(3)
      end
    end
  end
  context 'in Buildkite' do
    before(:each) do
      ENV['BUILDKITE'] = 'true'
      ENV['BUILDKITE_COMMIT'] = 'buildkite-commit-sha'
      ENV['BUILDKITE_BRANCH'] = 'buildkite-branch'
      ENV['BUILDKITE_PULL_REQUEST'] = 'false'
      ENV['BUILDKITE_BUILD_ID'] = 'buildkite-build-id'
    end

    it 'has the correct properties' do
      expect(Percy::Client::Environment.current_ci).to eq(:buildkite)
      expect(Percy::Client::Environment.branch).to eq('buildkite-branch')
      expect(Percy::Client::Environment._commit_sha).to eq('buildkite-commit-sha')
      expect(Percy::Client::Environment.pull_request_number).to be_nil
      expect(Percy::Client::Environment.repo).to eq('percy/percy-client') # From git, not env.
      expect(Percy::Client::Environment.parallel_nonce).to eq('buildkite-build-id')
      expect(Percy::Client::Environment.parallel_total_shards).to be_nil
    end
    context 'Pull Request build' do
      before(:each) do
        ENV['BUILDKITE_PULL_REQUEST'] = '123'
      end
      it 'has the correct properties' do
        expect(Percy::Client::Environment.pull_request_number).to eq('123')
      end
    end
    context 'UI-triggered HEAD build' do
      before(:each) do
        ENV['BUILDKITE_COMMIT'] = 'HEAD'
      end
      it 'has the correct properties' do
        expect(Percy::Client::Environment._commit_sha).to be_nil
      end
    end
  end
  context 'in Gitlab CI' do
    before(:each) do
      ENV['GITLAB_CI'] = 'yes'
      ENV['CI_BUILD_REF'] = 'gitlab-commit-sha'
      ENV['CI_BUILD_REF_NAME'] = 'gitlab-branch'
      ENV['CI_BUILD_ID'] = 'gitlab-build-id'
    end

    it 'has the correct properties' do
      expect(Percy::Client::Environment.current_ci).to eq(:gitlab)
      expect(Percy::Client::Environment.branch).to eq('gitlab-branch')
      expect(Percy::Client::Environment._commit_sha).to eq('gitlab-commit-sha')
      expect(Percy::Client::Environment.pull_request_number).to be_nil
      expect(Percy::Client::Environment.parallel_nonce).to eq('gitlab-build-id')
      expect(Percy::Client::Environment.parallel_total_shards).to be_nil
      # TODO: repo is deprecated, remove this:
      expect(Percy::Client::Environment.repo).to eq('percy/percy-client') # From git, not env.
    end
  end
  describe 'local git repo methods' do
    describe '#commit' do
      it 'returns current local commit data' do
        commit = Percy::Client::Environment.commit
        expect(commit[:branch]).to_not be_empty
        expect(commit[:sha]).to_not be_empty
        expect(commit[:sha].length).to eq(40)

        expect(commit[:author_email]).to match(/.+@.+\..+/)
        expect(commit[:author_name]).to_not be_empty
        expect(commit[:committed_at]).to_not be_empty
        expect(commit[:committer_email]).to_not be_empty
        expect(commit[:committer_name]).to_not be_empty
        expect(commit[:message]).to_not be_empty
      end
      it 'returns only branch if commit data cannot be found' do
        expect(Percy::Client::Environment).to receive(:_raw_commit_output).once.and_return(nil)

        commit = Percy::Client::Environment.commit
        expect(commit[:branch]).to be
        expect(commit[:sha]).to be_nil

        expect(commit[:author_email]).to be_nil
        expect(commit[:author_name]).to be_nil
        expect(commit[:committed_at]).to be_nil
        expect(commit[:committer_email]).to be_nil
        expect(commit[:committer_name]).to be_nil
        expect(commit[:message]).to be_nil
      end
    end
  end
end
