require 'api/spotify'
require 'api/auth/oauth_client_credentials'

module Api
  RSpec.describe Spotify do
    include InternalStructuresFactory

    before do
      allow_any_instance_of(Auth::OauthClientCredentials).to receive(:token).and_return('X')
    end

    describe '#find' do
      context 'when identity belongs to an artist' do
        let(:identity) { build_pi('Spotify', '2ye2Wgw4gimLv2eAKyk1NB', 'artist') }

        specify { expect(subject.find(identity)).to be_a(ProviderEntity) }

        it 'returns with the meta data of the artist' do
          expect(subject.find(identity).artist).to eq('Metallica')
          expect(subject.find(identity).album).to be_nil
          expect(subject.find(identity).track).to be_nil
          expect(subject.find(identity).kind).to eq('artist')
          expect(subject.find(identity).url).to eq('https://open.spotify.com/artist/2ye2Wgw4gimLv2eAKyk1NB')
        end
      end

      context 'when identity belongs to an album' do
        let(:identity) { build_pi('Spotify', '3wAdN3V06Btox7NjFfBKRC', 'album') }

        specify { expect(subject.find(identity)).to be_a(ProviderEntity) }

        it 'returns with the meta data of the album' do
          expect(subject.find(identity).artist).to eq('Metallica')
          expect(subject.find(identity).album).to eq('Death Magnetic')
          expect(subject.find(identity).track).to be_nil
          expect(subject.find(identity).kind).to eq('album')
          expect(subject.find(identity).url).to eq('https://open.spotify.com/album/3wAdN3V06Btox7NjFfBKRC')
        end
      end

      context 'when identity belongs to a track' do
        let(:identity) { build_pi('Spotify', '1FNZq0NV4yymW1wEjIi2eY', 'track') }

        specify { expect(subject.find(identity)).to be_a(ProviderEntity) }

        it 'returns with the meta data of the album' do
          expect(subject.find(identity).artist).to eq('Metallica')
          expect(subject.find(identity).album).to eq('Death Magnetic')
          expect(subject.find(identity).track).to eq('That Was Just Your Life')
          expect(subject.find(identity).kind).to eq('track')
          expect(subject.find(identity).url).to eq('https://open.spotify.com/track/1FNZq0NV4yymW1wEjIi2eY')
        end
      end

      context 'when identity belongs to a search' do
        let(:identity) { build_pi('Spotify', search_term, 'search') }

        context 'for an artist' do
          let(:search_term) { 'Daft Punk' }

          it 'returns with the meta data of a track' do
            track = subject.find(identity)

            expect(track).to be_a(ProviderEntity)
            expect(track.artist).to eq('Daft Punk')
            expect(track.album).to be_nil
            expect(track.track).to be_nil
            expect(track.kind).to eq('artist')
            expect(track.url).to eq('https://open.spotify.com/artist/4tZwfgrHOc3mvqYlEYSvVi')
          end
        end

        context 'for a track' do
          let(:search_term) { 'Daft Punk - Harder Better Faster Stronger' }

          it 'returns with the meta data of a track' do
            track = subject.find(identity)

            expect(track).to be_a(ProviderEntity)
            expect(track.artist).to eq('Daft Punk')
            expect(track.album).to eq('harder better faster stronger')
            expect(track.track).to eq('Harder Better Faster Stronger')
            expect(track.kind).to eq('track')
            expect(track.url).to eq('https://open.spotify.com/track/2cJz1loJp5EZM6shmQpLZN')
          end
        end
      end
    end

    describe '#search' do
      context 'when looking for an artist' do
        let(:entity) { build_pe('artist', 'UB40') }
        subject { described_class.new.search(entity) }

        it { is_expected.to be_a(ProviderEntity) }
        it 'returns with a match' do
          expect(subject.kind).to eq('artist')
          expect(subject.artist).to eq('UB40')
          expect(subject.album).to be_nil
          expect(subject.track).to be_nil
          expect(subject.url).to eq('https://open.spotify.com/artist/69MEO1AADKg1IZrq2XLzo5')
        end
      end

      context 'when looking for an album' do
        let(:entity) { build_pe('album', 'Metallica', 'Death Magnetic') }
        subject { described_class.new.search(entity) }

        it { is_expected.to be_a(ProviderEntity) }
        it 'returns with a match' do
          expect(subject.kind).to eq('album')
          expect(subject.url).to eq('https://open.spotify.com/album/3wAdN3V06Btox7NjFfBKRC')
          expect(subject.artist).to eq('') # Metallica - they're not including this
          expect(subject.album).to eq('Death Magnetic')
          expect(subject.track).to be_nil
        end
      end

      context 'when looking for an track' do
        let(:entity) { build_pe('track', 'UB40', 'The Very Best Of', 'One in Ten') }
        subject { described_class.new.search(entity) }

        it { is_expected.to be_a(ProviderEntity) }
        it 'returns with a match' do
          expect(subject.kind).to eq('track')
          expect(subject.artist).to eq('UB40')
          expect(subject.album).to eq('The Very Best Of')
          expect(subject.track).to eq('One in Ten')
          expect(subject.url).to eq('https://open.spotify.com/track/1dKfteL9OIYuFOCwBzV0SB')
        end
      end
    end
  end
end

