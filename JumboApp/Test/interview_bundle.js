'use strict';

/**
 * This file contains all the logic to "fake-run" operations.
 * By evaluating this file, a recurring timer is started.
 * This timer loops through the operations array, and updates their state.
 *
 * Adding operations can be accomplished by invoking `startOperation` with some
 *  id parameter, which will be used in the messages sent back to the native app
 *  via the messageHandler `jumbo`. This file expects there to be a message handler function
 *  registered at `window.webkit.messageHandlers.jumbo.postMessage` for these messages.
 * The `id` parameter is expected to be unique across all operations, and non-null. A random string should be used for this.
 *
 * The messages sent back to the native app will all contain an `id` property, matching that passed to the `startOperation` function.
 * The messages sent back to the native app will all contain a `message` property, which can be either `completed` or `progress`.
 * A `completed` message is the final message. No future messages will be delivered to the app for the operation referenced by the `id`.
 * A `completed message will also contain a `state` property, which gives information as to whether the operation completed successfully,
 *  or is considered "completed" due to an error that occurred.
 * A `progress` message will contain a `progress` property, an integer between 0 and 100 to represent the "percent" progress.
 * A `progress` message will be followed by one or many more subsequent messages to indicate further progress, or completion.
 */

// operations stores the state of all running (and completed) operations.

const operations = [];

// constants for state values.
const kStateStarted = "started"
const kStateError = "error"
const kStateSuccess = "success"

/**
 * invoke this function with an opaque, but required `id` paramater to start an operation.
 * Once invoked, the caller can expect at minimum one callback (via the message handler) referencing
 *  the operation by its id.
 */
function startOperation(id) {
    if (!id) {
        throw new Error("Expected id");
    }
    if (id === "") {
        throw new Error("Expected id");
    }
    for (const operation of operations) {
        if (id === operation.id) {
            throw new Error("Expected unique id")
        }
    }
    operations.push({
                    id: id,
                    progress: 0,
                    state: kStateStarted
                    });
}

// constants for message types
const kMessageCompleted = "completed"
const kMessageProgress = "progress"

/**
 * Messages the native app that an operation has failed.
 */
function messageOperationError(operationId) {
    const message = {
        id: operationId,
        message: kMessageCompleted,
        state: kStateError
    };
    window.webkit.messageHandlers.jumbo.postMessage(JSON.stringify(message));
}

/**
 * Messages the native app that progress has been made on an operation
 */
function messageProgress(operationId, progress) {
    const message = {
        id: operationId,
        message: kMessageProgress,
        progress: progress
    };
    window.webkit.messageHandlers.jumbo.postMessage(JSON.stringify(message));
}

/**
 * Messages the native app that an operation has succeeded
 */
function messageOperationSuccess(operationId) {
    const message = {
        id: operationId,
        message: kMessageCompleted,
        state: kStateSuccess
    };
    window.webkit.messageHandlers.jumbo.postMessage(JSON.stringify(message));
}

/**
 * Internal function to update the state of operations, and appropriately
 *  message the native app.
 */
function _tick() {
    for (const operation of operations) {
        const operationId = operation.id
        if (operation.progress == 100) {
            continue
        }
        if (operation.state === kStateError) {
            continue
        }
        if (operation.state === kStateSuccess) {
            continue
        }
        const shouldError = (Math.random() * 100) < 3;
        if (shouldError) {
            operation.state = kStateError
            messageOperationError(operation.id);
            continue
        }
        const skipProgressUpdate = (Math.random() * 100) < 20;
        if (skipProgressUpdate) {
            continue;
        }
        const progress = Math.floor(Math.random() * 20)
        if (operation.progress + progress >= 100) {
            operation.state = kStateSuccess
            operation.progress = 100
            messageOperationSuccess(operationId)
            continue
        }
        operation.progress = operation.progress + progress
        messageProgress(operationId, operation.progress)
    }
    setTimeout(_tick, 1000)
}

setTimeout(_tick, 1000)
