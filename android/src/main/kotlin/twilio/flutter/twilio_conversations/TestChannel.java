package twilio.flutter.twilio_conversations;

import io.flutter.plugin.common.StandardMethodCodec;
import io.flutter.plugin.common.MethodCodec;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.BinaryMessenger.BinaryMessageHandler;
import io.flutter.plugin.common.BinaryMessenger.BinaryReply;
import androidx.annotation.UiThread;
import java.nio.ByteBuffer;

public class TestChannel {
    private final BinaryMessenger messenger;
    private final String name;
    private final MethodCodec codec;

    public TestChannel(BinaryMessenger messenger, String name){
        this.messenger = messenger;
        this.name = name;
        this.codec = StandardMethodCodec.INSTANCE;
    }

    @UiThread
    public void setStreamHandler(final StreamHandler handler) {
        // We call the 2 parameter variant specifically to avoid breaking changes in
        // mock verify calls.
        // See https://github.com/flutter/flutter/issues/92582.
        messenger.setMessageHandler(
            name, handler == null ? null : new IncomingStreamRequestHandler(handler));
    }
    public interface StreamHandler {
        /**
         * Handles a request to set up an event stream.
         *
         * <p>Any uncaught exception thrown by this method will be caught by the channel implementation
         * and logged. An error result message will be sent back to Flutter.
         *
         * @param arguments stream configuration arguments, possibly null.
         * @param events an {@link EventSink} for emitting events to the Flutter receiver.
         */
        void onListen(Object arguments, EventSink events);
      }

    public interface EventSink {
        /**
         * Consumes a successful event.
         *
         * @param event the event, possibly null.
         */
        void success(Object event);
      }

    private final class IncomingStreamRequestHandler implements BinaryMessageHandler {
        private final StreamHandler handler;
        IncomingStreamRequestHandler(StreamHandler handler) {
            this.handler = handler;
        }

        @Override
        public void onMessage(ByteBuffer message, final BinaryReply reply) {
            System.out.println("receiving event");
            final MethodCall call = codec.decodeMethodCall(message);
            if (call.method.equals("listen")) {
                System.out.println("listening java side");
                onListen(call.arguments, reply);
            } 
        }

        private void onListen(Object arguments, BinaryReply callback) {
            final EventSink eventSink = new EventSinkImplementation();
            handler.onListen(arguments, eventSink);
            callback.reply(codec.encodeSuccessEnvelope(null));
        }
    }

    private final class EventSinkImplementation implements EventSink {
        @Override
        @UiThread
        public void success(Object event) {
          TestChannel.this.messenger.send(name, codec.encodeSuccessEnvelope(event));
        }
      }
}
