module Main where
import System.Environment
import Data.Char
import Numeric
import Data.Bits

transform len hex_str = orderize $ split $ (take (len - length hex_str) ['f','f'..]) ++ hex_str
    where split [] = []
          split (a:b:rest) = [a, b] : split rest
          orderize [] = []
          orderize (a:b:c:d:rest) = d:c:b:a: orderize rest
showTransformed [] = []
showTransformed (s: []) = "0x" ++ s
showTransformed (s:rest) = "0x" ++ s ++ ", " ++ (showTransformed rest)

transformNumber num = (complement num) + 1

main = do args <- getArgs
          putStrLn $ showHex ((read $ args !! 0) :: Integer) ""
          {-putStrLn $ showTransformed . transform 32 $ map toUpper $ showHex (transformNumber ((read $ args !! 0) :: Integer)) ""-}
