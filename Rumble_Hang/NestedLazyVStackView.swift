//
//  NestedLazyVStackView.swift
//  Rumble_Hang
//
//  Created by Michael Rozenblat on 27/01/2026.
//

import SwiftUI

struct NestedLazyVStackView: View {
    @State private var outerSections: [Int] = []
    @State private var isOuterLoading = false
    private let outerBatchSize = 10
    private let outerMax = 100
    
    @State private var innerRows: [Int: [Int]] = [:] // section: rows
    @State private var isInnerLoading: [Int: Bool] = [:]
    private let innerBatchSize = 10
    private let innerMax = 100
    
    var body: some View {
        ScrollView {
            // OUTER LazyVStack - Level 1
            LazyVStack(alignment: .leading, spacing: 24) {
                ForEach(outerSections, id: \.self) { section in
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Section #\(section)")
                            .font(.headline)
                        
                        // INNER LazyVStack - Level 2 (NESTED!)
                        // ⚠️ HANG OCCURS when Accessibility Inspector scans this nested lazy container
                        LazyVStack(alignment: .leading, spacing: 2) {
                            ForEach(innerRows[section] ?? [], id: \.self) { row in
                                Text("Section #\(section) - Row #\(row)")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.vertical, 6)
                                    .padding(.horizontal, 12)
                                    .background(Color(.secondarySystemBackground))
                                    .cornerRadius(6)
                                    .onAppear {
                                        // ⚠️ HANG TRIGGER POINT:
                                        // When this callback fires while Accessibility Inspector is scanning,
                                        // it triggers loadMoreInner() which adds new views to the LazyVStack
                                        // while the accessibility system is traversing it
                                        if let rows = innerRows[section],
                                           row == rows.last, !(isInnerLoading[section] ?? false), rows.count < innerMax {
                                            loadMoreInner(section: section)
                                        }
                                    }
                            }
                            if isInnerLoading[section] == true {
                                ProgressView().padding(.vertical, 8)
                            }
                        }
                    }
                    .padding(.bottom, 10)
                    .onAppear {
                        // ⚠️ HANG TRIGGER POINT:
                        // When this outer .onAppear fires while Accessibility Inspector is scanning,
                        // it adds new sections which creates more nested LazyVStacks
                        if section == outerSections.last, !isOuterLoading, outerSections.count < outerMax {
                            loadMoreOuter()
                        }
                    }
                }
                if isOuterLoading {
                    ProgressView().padding()
                }
            }
            .padding()
        }
        .navigationTitle("Nested LazyVStack")
        .onAppear {
            if outerSections.isEmpty {
                loadMoreOuter()
            }
        }
    }
    
    private func loadMoreOuter() {
        guard !isOuterLoading, outerSections.count < outerMax else { return }
        isOuterLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let nextStart = (outerSections.last ?? 0) + 1
            let nextEnd = min(nextStart + outerBatchSize - 1, outerMax)
            let newSections = Array(nextStart...nextEnd)
            outerSections.append(contentsOf: newSections)
            // Initialize inner rows for new sections
            for section in newSections {
                innerRows[section] = Array(1...innerBatchSize)
                isInnerLoading[section] = false
            }
            isOuterLoading = false
        }
    }
    
    private func loadMoreInner(section: Int) {
        guard !(isInnerLoading[section] ?? false), let currentRows = innerRows[section], currentRows.count < innerMax else { return }
        isInnerLoading[section] = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let nextStart = currentRows.count + 1
            let nextEnd = min(currentRows.count + innerBatchSize, innerMax)
            let newRows = Array(nextStart...nextEnd)
            innerRows[section, default: []].append(contentsOf: newRows)
            isInnerLoading[section] = false
        }
    }
}

#Preview {
    NestedLazyVStackView()
}
