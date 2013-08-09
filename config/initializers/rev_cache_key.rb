def rev_cache_key(key, type=:compiled)
  "#{key}/#{ASSET_IDS[type]}"
end