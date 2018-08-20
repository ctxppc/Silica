# Silica
**Silica** is a developer tool that generates localised strings from Swift code, without ever having to touch `NSLocalizedString`, `String.localizedStringWithFormat`, and related functions.

Silica is a work in progress in its earliest stages. Most features documented here aren't fully implemented or working properly yet.

## Usage
Define an `enum` type for every group of related localisable strings. Define a `case` for every string. For example,

	class PopularVideosViewController : UIViewController {
		// …
		
		/// A title used on an item in the tab bar.
		enum TabItemTitle : LocalisableString {
			
			/// The tab title for popular videos in the user's viscinity.
			case nearby
			
			/// The tab title for videos popular with the user's friends.
			case friends
			
			/// The tab title for all-time popular videos.
			case allTime
			
		}
		
	}

Cases can have associated values. Supported types are `Int`, `Double`, and `String`. Associated values are localised by the system and can affect the pluralisation of the localised string (via rules in `.stringdict`).

	class ProfileViewController : UIViewController {
		// …
		enum Title : LocalisableString {
			
			/// The user isn't logged in.
			case notLoggedIn
			
			/// The user is logged in as `nickname`.
			case loggedIn(nickname: String)
			
		}
	}

Silica generates one localisation file (`.strings` or `.stringdict`) per `LocalisableString` type. The files are named after the `LocalisableString` fully-qualified name but with `ViewController` and `String` omitted. The two examples above would result in two localisation files per locale: `PopularVideos.Title.strings` and `Profile.Title.strings`.

Documentation comments on `enum`s and `case`s are copied as notes for the translator.

When installed as a build phase in Xcode, Silica updates its generated conformance and localisation files at every build. Silica generates new files and string keys for new `enum`s and cases but also removes keys for removed `enum`s and cases when the keys don't have an associated localised string value yet.

## Installation (Xcode)
**Warning:** Silica is an early work in progress. Make sure you don't have any uncommitted changes in your project before using Silica.

First, check out the repository, then build and install Silica. This step only needs to be done once on each machine.

	cd path_to_silica_repository                        # go to the Silica repository
	swift build -c release                              # build the Silica binary
	cp -f .build/release/Silica /usr/local/bin/silica   # install the binary in the standard location

Next, add a *Run Script* build phase to your target invoking Silica. This phase must precede the *Compile Sources* phase.

1. With the project open in Xcode, select the project in the Project Navigator.
2. Select the relevant target (e.g., the app) under Targets in the Editor.
3. Select the Build Phases tab in the Editor.
4. Press the plus sign (+) under the tab bar and select "New Run Script Phase".
5. Move the newly created Run Script build phase *above* the Compile Sources build phase.
6. Enter `silica` on line 1 in the script editor.

Then, build the project. Silica will create a new file `Localisable Strings.swift` in the project's directory. Add this file to your project and target by dragging it from the Finder or using the *Add Files to Project* menu item in Xcode. You can use the `LocalisableString` protocol now.