module Sass
  module CacheStores
    class Dalli < Base
      def _store(key, version, sha, contents)
        ::Rails.cache.write(Digest::SHA1.hexdigest(rev_cache_key("#{key}/#{version}/#{sha}", :css)), contents, :expires_in => 1.week)
      end

      def _retrieve(key, version, sha)
        ::Rails.cache.read(Digest::SHA1.hexdigest(rev_cache_key("#{key}/#{version}/#{sha}", :css)))
      end
    end
  end
end
