//
//  ModelSelectable.swift
//  translate_tool
//
//  Created by cenk on 2024-12-12.
//

protocol ModelSelectable {
    func listModels() async throws -> Set<String>
}
