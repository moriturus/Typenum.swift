// =============================================================================
// GeneratedConsts.swift — Source-directory placeholder
// =============================================================================
//
// This file intentionally contains no code.
//
// WHY IT EXISTS
// -------------
// The Typenum target applies the TypenumPlugin build-tool plugin (see
// Package.swift).  During every build, TypenumPlugin runs the TypenumCodegen
// executable, which writes a file called GeneratedProofs.swift into the
// plugin's work directory (pluginWorkDirectoryURL).  That generated file
// currently contains the canonical typealias constants (U0…U1024, P1…P1024,
// N1…N1024) that are too numerous or mechanical to maintain by hand.
//
// The generated file also reserves proof-oriented sections for future
// expansion.  At present those sections are scaffolding only and do not emit
// additional public declarations.
//
// SPM requires a build-tool plugin's output directory to correspond to a
// real target source directory.  If this directory contained *only*
// plugin-generated files and no checked-in Swift sources, SPM would not
// recognise it as a valid target during dependency resolution — before the
// plugin has had a chance to run.  Keeping at least one committed .swift
// file here satisfies that requirement.
//
// DO NOT add production code to this file.  All generated declarations live
// in the plugin output; see Sources/TypenumCodegen/main.swift for the
// generation logic and Plugins/TypenumPlugin/plugin.swift for the build
// command definition.
// =============================================================================
