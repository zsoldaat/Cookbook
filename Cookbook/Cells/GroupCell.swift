//
//  GroupCell.swift
//  Cookbook
//
//  Created by Zac Soldaat on 2025-02-17.
//

import SwiftUI
import SwiftData

struct GroupCell: View {
    let group: RecipeGroup
    
    let imageSize: CGFloat = 90

    var body: some View {
        
        HStack(spacing: 10) {
            
            ZStack {
                RoundedRectangle(cornerRadius: 3)
                    .fill({
                        deterministicColor(for: group.name)
                    }())
                Text(group.name.first!.uppercased())
                    .font(.system(size: 50, weight: .regular))
                    .foregroundStyle(.white)
            }
            .frame(width: imageSize, height: imageSize)
            .clipShape(RoundedRectangle(cornerRadius: 15))
            
            VStack(alignment: .leading) {
                Text(group.name).font(.headline)
                
                Text("\(group.shareParticipants.map{$0.firstName}.joined(separator: ","))").lineLimit(1).font(.subheadline).foregroundStyle(.secondary, .secondary)
                
                HStack {
                    if (group.isShared) {
                        Image(systemName: "person.circle")
                            .resizable()
                            .frame(width: 15, height: 15)
                            .foregroundStyle(.accent)
                    }
                }
            }
        }
    }
}


// MARK: - Deterministic Color from String

private func deterministicColor(for string: String, saturation: Double = 0.6, brightness: Double = 0.9) -> Color {
    // FNV-1a 64-bit hash for stability across launches/devices
    let fnvOffsetBasis: UInt64 = 0xcbf29ce484222325
    let fnvPrime: UInt64 = 0x100000001b3

    var hash: UInt64 = fnvOffsetBasis
    for byte in string.utf8 {
        hash ^= UInt64(byte)
        hash &*= fnvPrime
    }

    // Map hash to a hue in [0, 1)
    let hue = Double(hash % 360) / 360.0
    return Color(hue: hue, saturation: saturation, brightness: brightness)
}
