module Main where

greet :: String -> String
greet name = "Hello, " ++ name ++ "!"

main :: IO ()
main = putStrLn (greet "World")

-- Indent/fold fixture: the definitions above are one-liners with nothing to
-- fold, which reads as "folding is broken" when it is the file that is thin.
-- See openspec TEST_PLAN, change align-treesitter-providers, AT.2/AT.8.

data Shape
  = Circle Double
  | Rect Double Double
  deriving (Show, Eq)

area :: Shape -> Double
area shape =
  case shape of
    Circle r ->
      pi * r * r
    Rect w h ->
      w * h

describe :: Shape -> String
describe s
  | area s > 100 = "large"
  | area s > 10  = "medium"
  | otherwise    = "small"

summarise :: [Shape] -> IO ()
summarise shapes = do
  let total = sum (map area shapes)
  mapM_ (putStrLn . describe) shapes
  print total
