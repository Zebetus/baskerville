module Baskerville.Chunk.Generators where

import Data.Array.ST
import Data.Word

import Baskerville.Chunk
import Baskerville.Coords

-- | Write a plane of data all at once.
plane :: (MArray a e m) => a BCoord e -> Word8 -> e -> m ()
plane array y value = let
    as = repeat array
    vs = repeat value
    ixs = range (BCoord y 0 0, BCoord y 15 15)
    in sequence_ $ zipWith3 writeArray as ixs vs

-- | Ensure that the chunk has safety features enabled.
safety :: Generator
safety i mmc = case mmc of
    Nothing -> Nothing
    Just (MicroChunk ca) -> case i of
        0x0 -> Just . MicroChunk $ runSTArray $ do
            a <- thaw ca
            plane a 0x0 0x1
            return a
        0xf -> Just . MicroChunk $ runSTArray $ do
            a <- thaw ca
            plane a 0xe 0x0
            plane a 0xf 0x0
            return a

-- | Put some boring things into the chunk.
boring :: Generator
boring i _
    | i < 8 = Just . MicroChunk $ runSTArray $ do
        a <- thaw $ newFilledArray 0x0
        plane a 0xf 0x2
        plane a 0x0 0x4
        return a
    | otherwise = Nothing

-- | Bedrock only.
bedrock :: Generator
bedrock 0 _ = Just . MicroChunk $ newFilledArray 0x1
bedrock _ _ = Nothing

-- | Less boring stuff. Stripes of material.
stripes :: Generator
stripes i _ = case i of
    0x0 -> Just . MicroChunk $ newFilledArray 0x1
    0x2 -> Just . MicroChunk $ newFilledArray 0x2
    0x4 -> Just . MicroChunk $ newFilledArray 0x3
    0x6 -> Just . MicroChunk $ newFilledArray 0x4
    0x8 -> Just . MicroChunk $ newFilledArray 0x5
    0xa -> Just . MicroChunk $ newFilledArray 0x6
    _   -> Nothing
