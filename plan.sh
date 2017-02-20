pkg_name=welcome_bot
pkg_origin=chef
pkg_version=_computed_in_a_function_below_
pkg_description="This is a github bot to ensure new users who submit PRs or issues
  to your org are greated with a special welcome message that includes getting
  started help."
pkg_upstream_url=https://github.com/chef/welcome_bot
pkg_maintainer="Chef Community Engineering Team <community@chef.io>"
pkg_license=('Apache 2.0')
pkg_source=false
pkg_deps=(
  core/cacerts
  core/coreutils
  core/ruby
)
pkg_build_deps=(
  core/bundler
  core/git
)
pkg_bin_dirs=(bin)
pkg_svc_run="welcome_bot"
pkg_expose=(8080)

determine_version() {
  # Ask the welcome_bot gem what version it is. Use that as the hab package version.
  # Only have to set/bump version in one place like we would for any gem.
  pkg_version=$(ruby -Ilib/wb -rversion -e 'puts WelcomeBot::VERSION')
  pkg_dirname=${pkg_name}-${pkg_version}
  pkg_filename=${pkg_dirname}.tar.gz
  pkg_prefix=$HAB_PKG_PATH/${pkg_origin}/${pkg_name}/${pkg_version}/${pkg_release}
  pkg_artifact="$HAB_CACHE_ARTIFACT_PATH/${pkg_origin}-${pkg_name}-${pkg_version}-${pkg_release}-${pkg_target}.${_artifact_ext}"
}

do_download() {
  determine_version

  # Instead of downloading, build a gem based on the source
  cd $PLAN_CONTEXT
  gem build $pkg_name.gemspec
}

do_verify() {
  # No download to verify.
  return 0
}

do_unpack() {
  # Unpack the gem we built to the source cache path. Building then unpacking
  # the gem reuses the file inclusion/exclusion rules defined in the gemspec.
  gem unpack $PLAN_CONTEXT/$pkg_name-$pkg_version.gem --target=$HAB_CACHE_SRC_PATH
}

do_build() {
  export GIT_DIR=$PLAN_CONTEXT/.git # appease the git command in the gemspec
  export BUNDLE_SILENCE_ROOT_WARNING=1 GEM_PATH
  GEM_PATH="$(pkg_path_for core/bundler)"

  bundle install --jobs "$(nproc)" --retry 5 --standalone \
    --without development \
    --path "bundle" \
    --binstubs
}

do_install () {
  fix_interpreter "bin/*" core/coreutils bin/env
  cp -a "." "$pkg_prefix"
}
