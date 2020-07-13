//
// ChatLayout
// LayoutModel.swift
// https://github.com/ekazaev/ChatLayout
//
// Created by Eugene Kazaev in 2020.
// Distributed under the MIT license.
//

import Foundation
import UIKit

struct LayoutModel {

    var sections: [SectionModel]

//    var viewPort: CGRect
//
//    var adjustedContentInsets: UIEdgeInsets
//
    private unowned var collectionLayout: ChatLayout

    init(sections: [SectionModel], collectionLayout: ChatLayout) {
        self.sections = sections
        self.collectionLayout = collectionLayout
//        self.viewPort = collectionLayout.viewPort
//        self.adjustedContentInsets = collectionLayout.adjustedContentInset
    }

    mutating func assembleLayout() {
        var offset: CGFloat = collectionLayout.settings.additionalInsets.top

        for index in 0..<sections.count {
            sections[index].offsetY = offset
            offset += sections[index].height + collectionLayout.settings.interSectionSpacing
        }
    }

    // MARK: To use when its is important to make the correct insertion

    mutating func setAndAssemble(section: SectionModel, sectionIndex: Int) {
        guard sectionIndex < sections.count else {
            fatalError()
        }
        let oldSection = sections[sectionIndex]
        sections[sectionIndex] = section
        let heightDiff = sections[sectionIndex].height - oldSection.height
        offsetEverything(below: sectionIndex, by: heightDiff)
    }

    mutating func setAndAssemble(header: ItemModel?, sectionIndex: Int) {
        guard sectionIndex < sections.count else {
            fatalError()
        }

        let oldSection = sections[sectionIndex]
        sections[sectionIndex].setAndAssemble(header: header)
        let heightDiff = sections[sectionIndex].height - oldSection.height
        offsetEverything(below: sectionIndex, by: heightDiff)
    }

    mutating func setAndAssemble(item: ItemModel, sectionIndex: Int, itemIndex: Int) {
        guard sectionIndex < sections.count else {
            fatalError()
        }
        let oldSection = sections[sectionIndex]
        sections[sectionIndex].setAndAssemble(item: item, at: itemIndex)
        let heightDiff = sections[sectionIndex].height - oldSection.height
        offsetEverything(below: sectionIndex, by: heightDiff)
    }

    mutating func setAndAssemble(footer: ItemModel?, sectionIndex: Int) {
        guard sectionIndex < sections.count else {
            fatalError()
        }
        let oldSection = sections[sectionIndex]
        sections[sectionIndex].setAndAssemble(footer: footer)
        let heightDiff = sections[sectionIndex].height - oldSection.height
        offsetEverything(below: sectionIndex, by: heightDiff)
    }

    private mutating func offsetEverything(below index: Int, by heightDiff: CGFloat) {
        guard heightDiff != 0 else {
            return
        }
        if index < sections.count - 1 {
            for index in (index + 1)..<sections.count {
                sections[index].offsetY += heightDiff
            }
        }
    }

    // MARK: To use only withing process(updateItems:)

    mutating func insertSection(_ section: SectionModel, at sectionIndex: Int, at state: ModelState) {
        var sections = self.sections
        guard sectionIndex <= sections.count else {
            fatalError("Incorrect index section")
        }

        sections.insert(section, at: sectionIndex)
        self.sections = sections
    }

    mutating func removeSection(by sectionIdentifier: UUID, at state: ModelState) {
        guard let sectionIndex = sections.firstIndex(where: { $0.id == sectionIdentifier }) else {
            fatalError()
        }
        sections.remove(at: sectionIndex)
    }

    mutating func removeSection(for sectionIndex: Int, at state: ModelState) {
        sections.remove(at: sectionIndex)
    }

    mutating func removeRow(by identifier: ItemIdentifier, at state: ModelState) {
        guard let sectionIndex = sections.firstIndex(where: { $0.id == identifier.sectionId }) else {
            fatalError("Incorrect identifier")
        }
        sections[sectionIndex].remove(by: identifier.itemId)
    }

    mutating func removeItem(for indexPath: IndexPath, at state: ModelState) {
        sections[indexPath.section].remove(at: indexPath.item)
    }

    mutating func insertItem(_ item: ItemModel, at indexPath: IndexPath, at state: ModelState) {
        sections[indexPath.section].insert(item, at: indexPath.item)
    }

}
