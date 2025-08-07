/*
 * (c) Copyright IBM Corp. 2021
 * (c) Copyright Instana Inc. and contributors 2021
 */

package com.instana.flutter.agent

import android.app.Application
import androidx.annotation.NonNull

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.util.regex.Pattern
import java.util.*
import kotlin.collections.HashMap

/** InstanaAgentPlugin */
class InstanaAgentPlugin : FlutterPlugin, MethodCallHandler {

    private var channel: MethodChannel? = null
    private var app: Application? = null

    private val nativeLink = NativeLink()

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "instana_agent").apply {
            setMethodCallHandler(this@InstanaAgentPlugin)
        }

        app = flutterPluginBinding.applicationContext as? Application
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "setup" -> {
                val key: String? = call.argument("key")
                val reportingUrl: String? = call.argument("reportingUrl")
                val collectionEnabled: Boolean? = call.argument("collectionEnabled")
                val captureNativeHttp: Boolean? = call.argument("captureNativeHttp")
                val slowSendIntervalSeconds: Double? = call.argument("slowSendInterval")
                val usiRefreshTimeIntervalInHrs: Double? =
                    call.argument("usiRefreshTimeIntervalInHrs")
                val queryTrackedDomainListArr: List<String>? = call.argument("queryTrackedDomainList")
                val dropBeaconReporting: Boolean? = call.argument("dropBeaconReporting")
                val rateLimits: Int? = call.argument("rateLimits")
                val enableW3CHeaders: Boolean? = call.argument("enableW3CHeaders")
                val hybridAgentId: String? = call.argument("hybridAgentId")
                val hybridAgentVersion: String? = call.argument("hybridAgentVersion")
                val trustDeviceTiming: Boolean? = call.argument("trustDeviceTiming")
                // Convert to Immutable List of Pattern
                val queryTrackedDomainList: List<Pattern>? = queryTrackedDomainListArr?.map { it.toRegex().toPattern() }
                return nativeLink.setUpInstana(
                    result = result,
                    app = app,
                    reportingUrl = reportingUrl,
                    key = key,
                    collectionEnabled = collectionEnabled,
                    captureNativeHttp = captureNativeHttp,
                    slowSendInterval = slowSendIntervalSeconds,
                    usiRefreshTimeIntervalInHrs = usiRefreshTimeIntervalInHrs,
                    queryTrackedDomainList = queryTrackedDomainList,
                    dropBeaconReporting = dropBeaconReporting,
                    rateLimits = rateLimits,
                    enableW3CHeaders = enableW3CHeaders,
                    hybridAgentId = hybridAgentId,
                    hybridAgentVersion = hybridAgentVersion,
                    trustDeviceTiming = trustDeviceTiming ?: false
                )
            }

            "setCollectionEnabled" -> {
                val collectionEnabled: Boolean? = call.argument("collectionEnabled")
                if (collectionEnabled != null) {
                    nativeLink.setCollectionEnabled(
                        result = result,
                        collectionEnabled = collectionEnabled
                    )
                }
            }

            "setUserID" -> {
                val userID: String? = call.argument("userID")
                nativeLink.setUserId(
                    result = result,
                    userID = userID
                )
            }

            "setUserName" -> {
                val userName: String? = call.argument("userName")
                nativeLink.setUserName(
                    result = result,
                    userName = userName
                )
            }

            "setUserEmail" -> {
                val userEmail: String? = call.argument("userEmail")
                nativeLink.setUserEmail(
                    result = result,
                    userEmail = userEmail
                )
            }

            "setView" -> {
                val viewName: String? = call.argument("viewName")
                nativeLink.setView(
                    result = result,
                    viewName = viewName
                )
            }

            "getView" -> {
                result.success(nativeLink.getView())
            }

            "getSessionID" -> {
                result.success(nativeLink.getSessionID())
            }

            "setMeta" -> {
                val key: String? = call.argument("key")
                val value: String? = call.argument("value")
                nativeLink.setMeta(
                    result = result,
                    key = key,
                    value = value
                )
            }

            "setCaptureHeaders" -> {
                val list: List<String?>? = call.argument("regex")
                nativeLink.setCaptureHeaders(
                    result = result,
                    regex = list
                )
            }

            "redactHTTPQuery" -> {
                val list: List<String?>? = call.argument("redactHTTPQueryRegEx")
                nativeLink.redactHTTPQuery(
                    result = result,
                    regex = list
                )
            }

            "reportEvent" -> {
                val eventName: String? = call.argument("eventName")
                val startTime: Double? = call.argument("startTime")
                val duration: Double? = call.argument("duration")
                val viewName: String? = call.argument("viewName")
                val meta: HashMap<String?, String?>? = call.argument("meta")
                val backendTracingID: String? = call.argument("backendTracingID")
                val customMetric: Double? = call.argument("customMetric")
                nativeLink.reportEvent(
                    result = result,
                    eventName = eventName,
                    startTime = startTime,
                    duration = duration,
                    viewName = viewName,
                    meta = meta,
                    backendTracingID = backendTracingID,
                    customMetric = customMetric
                )
            }

            "startCapture" -> {
                val url: String? = call.argument("url")
                val method: String? = call.argument("method")
                val viewName: String? = call.argument("viewName")
                nativeLink.startCapture(
                    result = result,
                    url = url,
                    method = method,
                    viewName = viewName
                )
            }

            "finish" -> {
                val markerId: String? = call.argument("id")
                val responseStatusCode: Int? = call.argument("responseStatusCode")
                val responseSizeEncodedBytes: Long? =
                    (call.argument("responseSizeBody") as? Int)?.toLong()
                val responseSizeDecodedBytes: Long? =
                    (call.argument("responseSizeBodyDecoded") as? Int)?.toLong()
                val backendTraceId: String? = call.argument("backendTracingID")
                val errorMessage: String? = call.argument("errorMessage")
                val responseHeaders: HashMap<String?, String?>? = call.argument("responseHeaders")
                nativeLink.finishCapture(
                    result = result,
                    markerId = markerId,
                    responseStatusCode = responseStatusCode,
                    responseSizeEncodedBytes = responseSizeEncodedBytes,
                    responseSizeDecodedBytes = responseSizeDecodedBytes,
                    backendTraceId = backendTraceId,
                    errorMessage = errorMessage,
                    responseHeaders = responseHeaders
                )
            }

            "cancel" -> {
                val markerId: String? = call.argument("id")
                nativeLink.cancelCapture(
                    result = result,
                    markerId = markerId
                )
            }

            "setInternalMeta" -> {
                val key: String? = call.argument("key")
                val value: String? = call.argument("value")
                nativeLink.setInternalMeta(
                    result = result,
                    key = key,
                    value = value
                )
            }

            "clearInternalMeta" -> {
                nativeLink.clearInternalMeta(result = result)
            }

            else -> {
                result.notImplemented()
            }
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel?.setMethodCallHandler(null)
    }

}
