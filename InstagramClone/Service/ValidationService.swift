//
//  ValidationService.swift
//  InstagramClone
//
//  Created by Albert Lin on 2022/4/23.
//

import Foundation

class ValidationService {
    func isSignUpPasswordValid(password1: String, password2: String) -> SignUpPasswordValidationResult {
        if (password1 != password2) {
            return SignUpPasswordValidationResult.PasswordNotMatch
        }
        if (password1.count < 6) {
            return SignUpPasswordValidationResult.PasswordLengthNotEnough
        }
        
        return SignUpPasswordValidationResult.PasswordValid
    }
}

enum SignUpPasswordValidationResult {
    case PasswordNotMatch
    case PasswordLengthNotEnough
    case PasswordValid
}

