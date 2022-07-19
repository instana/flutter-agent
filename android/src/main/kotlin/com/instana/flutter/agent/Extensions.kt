package com.instana.flutter.agent

fun Map<String?, String?>.filterNotNull(): Map<String, String> {
    val filtered = mutableMapOf<String, String>()
    this.forEach { header ->
        val key = header.key
        val value = header.value
        if (key != null && value != null) {
            filtered[key] = value
        }
    }
    return filtered
}
