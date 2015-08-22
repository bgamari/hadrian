module Rules.Documentation (buildPackageDocumentation) where

import Way
import Base
import Stage
import Builder
import Package
import Expression
import Oracles.PackageData
import Target (PartialTarget (..), fullTarget, fullTargetWithWay)
import Settings.TargetDirectory
import Rules.Actions
import Rules.Resources
import Settings.Util
import Settings.User
import Settings.Packages

-- Note: this build rule creates plenty of files, not just the .haddock one.
-- All of them go into the 'doc' subdirectory. Pedantically tracking all built
-- files in the Shake databases seems fragile and unnecesarry.
buildPackageDocumentation :: Resources -> PartialTarget -> Rules ()
buildPackageDocumentation _ target @ (PartialTarget stage pkg) =
    let cabalFile   = pkgCabalFile pkg
        haddockFile = pkgHaddockFile pkg
    in when (stage == Stage1) $ do

        haddockFile %> \file -> do
            whenM (specified HsColour) $ do
                need [cabalFile]
                build $ fullTarget target GhcCabalHsColour [cabalFile] []
            srcs <- interpretPartial target getPackageSources
            deps <- interpretPartial target $ getPkgDataList DepNames
            let haddocks = [ pkgHaddockFile depPkg
                           | Just depPkg <- map findKnownPackage deps ]
            need $ srcs ++ haddocks
            let haddockWay = if dynamicGhcPrograms then dynamic else vanilla
            build $ fullTargetWithWay target Haddock haddockWay srcs [file]

-- $$($1_PACKAGE)-$$($1_$2_VERSION)_HADDOCK_DEPS =
--    $$(foreach n,$$($1_$2_DEPS)
--        ,$$($$n_HADDOCK_FILE) $$($$n_dist-install_$$(HADDOCK_WAY)_LIB))

-- $$($$($1_PACKAGE)-$$($1_$2_VERSION)_HADDOCK_FILE) :
--     $$$$($$($1_PACKAGE)-$$($1_$2_VERSION)_HADDOCK_DEPS) | $$$$(dir $$$$@)/.

-- # Make the haddocking depend on the library .a file, to ensure
-- # that we wait until the library is fully built before we haddock it
-- $$($$($1_PACKAGE)-$$($1_$2_VERSION)_HADDOCK_FILE) : $$($1_$2_$$(HADDOCK_WAY)_LIB)
-- endif