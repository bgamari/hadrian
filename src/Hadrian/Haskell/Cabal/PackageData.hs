module Hadrian.Haskell.Cabal.PackageData where

import Development.Shake.Classes
import Hadrian.Package.Type
import GHC.Generics

data PackageData = PackageData
    { dependencies :: [PackageName]
    , name         :: PackageName
    , version      :: String
    -- * used to be pkg Data
    , componentId  :: String
    , modules      :: [String]
    , otherModules :: [String]
    , synopsis     :: String
    , description  :: String
    , srcDirs      :: [String]
    , deps         :: [String]
    , depIpIds     :: [String]
    , depNames     :: [String]
    , depCompIds   :: [String]
    , includeDirs  :: [String]
    , includes     :: [String]
    , installIncludes :: [String]
    , extraLibs    :: [String]
    , extraLibDirs :: [String]
    , asmSrcs      :: [String]
    , cSrcs        :: [String]
    , cmmSrcs      :: [String]
    , dataFiles    :: [String]
    , hcOpts       :: [String]
    , asmOpts      :: [String]
    , ccOpts       :: [String]
    , cmmOpts      :: [String]
    , cppOpts      :: [String]
    , ldOpts       :: [String]
    , depIncludeDirs :: [String]
    , depCcOpts    :: [String]
    , depLdOpts    :: [String]
    , buildGhciLib :: Bool
    } deriving (Eq, Read, Show, Typeable, Generic)

instance Binary PackageData

instance Hashable PackageData
instance NFData PackageData
