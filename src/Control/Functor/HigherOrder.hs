-----------------------------------------------------------------------------
-- |
-- Module      :  Control.Functor.HigherOrder
-- Copyright   :  (C) 2008 Edward Kmett
-- License     :  BSD-style (see the file LICENSE)
--
-- Maintainer  :  Edward Kmett <ekmett@gmail.com>
-- Stability   :  experimental
-- Portability :  non-portable (rank-2 polymorphism)
--
-- Neil Ghani and Particia Johann''s higher order functors from
-- <http://crab.rutgers.edu/~pjohann/tlca07-rev.pdf>
----------------------------------------------------------------------------
module Control.Functor.HigherOrder 
	( HFunctor(..)
	, HPointed(..)
	, HCopointed(..)
	, AlgH
	, CoAlgH
	, FixH(..)
	) where

import Control.Functor.Extras

type AlgH f g = Natural (f g) g
type CoAlgH f g = Natural g (f g)

class HFunctor f where
	ffmap :: Functor g => (a -> b) -> f g a -> f g b
	hfmap :: Natural g h -> Natural (f g) (f h)

newtype FixH f a = InH { outH :: f (FixH f) a }

class HFunctor m => HPointed m where
	hreturn  :: Functor f => Natural f (m f)

class HFunctor w => HCopointed w where
	hextract :: Functor f => Natural (w f) f

