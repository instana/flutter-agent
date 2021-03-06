/*
 * (c) Copyright IBM Corp. 2021
 * (c) Copyright Instana Inc. and contributors 2021
 */

package com.instana.flutter.agent

/**
 * Error codes Instana Flutter Agent could return
 **/
enum class ErrorCode(val serialized: String) {
    MISSING_OR_INVALID_ARGUMENT("missingOrInvalidArg"),
    NOT_SETUP("instanaNotSetup"),
    META_LIST_FULL("metaListFull"),
}
