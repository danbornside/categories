{-# LANGUAGE ConstraintKinds #-}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE GADTs #-}
{-# LANGUAGE KindSignatures #-}
{-# LANGUAGE PolyKinds #-}
{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE TypeOperators #-}

module Math.Multicategory 
  ( Forest(..)
  , Multicategory(..)
  -- * Utilities 
  , inputs, outputs
  , splitForest
  ) where

import Data.Constraint
import Data.Proxy
import Math.Category
import Math.Rec
import Math.Rec.All
import Prelude (($), undefined)

--------------------------------------------------------------------------------
-- * Forests
--------------------------------------------------------------------------------

data Forest :: ([i] -> i -> *) -> [i] -> [i] -> * where
  Nil :: Forest f '[] '[]
  (:-) :: f k o -> Forest f m n -> Forest f (k ++ m) (o ': n)

inputs  :: forall f g is os. (forall as b. f as b -> Rec g as) -> Forest f is os -> Rec g is
inputs _ Nil = RNil 
inputs f (a :- as) = f a `appendRec` inputs f as

outputs :: (forall as b. f as b -> p b) -> Forest f is os -> Rec p os
outputs f Nil = RNil
outputs f (a :- as) = f a :& outputs f as

splitForest :: forall f g ds is js os r. Rec f is -> Forest g js os -> Forest g ds (is ++ js)
            -> (forall bs cs. (ds ~ (bs ++ cs)) => Forest g bs is -> Forest g cs js -> r) -> r
splitForest RNil bs as k = k Nil as
splitForest (i :& is) bs ((j :: g as o) :- js) k = splitForest is bs js $
  \ (l :: Forest g bs as1) (r :: Forest g cs js) ->
    case appendAssocAxiom (Proxy :: Proxy as) (Proxy :: Proxy bs) (Proxy :: Proxy cs) of
      Dict -> k (j :- l) r

--------------------------------------------------------------------------------
-- * Multicategories
--------------------------------------------------------------------------------

class Multicategory (f :: [i] -> i -> *) where
  type Mob f :: i -> Constraint
  type Mob f = Vacuous
  ident   :: Mob f a => f '[a] a
  compose :: f bs c -> Forest f as bs -> f as c
  sources :: f as b -> Rec (Dict1 (Mob f)) as
  mtarget :: f as b -> Dict1 (Mob f) b

instance Multicategory f => Category (Forest f) where
  type Ob (Forest f) = All (Mob f)

  id = go proofs where
    go :: Rec (Dict1 (Mob f)) is -> Forest f is is
    go (Dict1 :& as) = ident :- go as
    go RNil          = Nil

  Nil . Nil = Nil
  (b :- bs) . as = splitForest (sources b) bs as $ \es fs -> compose b es :- (bs . fs)

  source = reproof . inputs sources
  target = reproof . outputs mtarget
