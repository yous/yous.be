RSpec.describe '_site' do
  include JekyllHelper

  context 'timezone' do
    it 'uses KST instead of UTC' do
      [
        %w(2013 02 19 ios-6.1-music-album-shuffle index.html),
        %w(2013 12 03 syntax-highlighting-test index.html),
        %w(2014 02 23 apples-ssl-tls-bug index.html),
        %w(2014 04 03 fragment-transaction-and-activity-state-loss index.html),
        %w(2014 05 12 layout-inflation-as-intended index.html),
        %w(2014 07 18 using-keybase index.html),
        %w(2014 09 21 yet-another-hex-word index.html),
        %w(2014 12 09 seccon-ctf-2014-easy-cipher-write-up index.html),
        %w(2014 12 26 christmasctf-2014-write-up index.html)
      ].each do |post_dirs|
        expect(File.exist?(dest_dir(post_dirs))).to be_truthy
      end
    end
  end
end
