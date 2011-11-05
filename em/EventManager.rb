Event = Struct.new(:sender,
                   :name)

class EventManager
    class << self
        def setup

            @@senders    = {} # Instances Sending Event Messages
            @@registrars = [] # Instances Receiving Event Messages
            @@events     = [] # List of Event objects
            @@dispatch   = {} # Event IDs mapped to relevant registrars

        end

        def add_sender( desc, sender )

            raise ArgumentError, "Sender \'#{ desc }\' Already Exists" if @@senders.has_key? desc
            @@senders[ desc ]  = sender  # Add sender if unique
        end

        def add_event( sender, event )

            raise ArgumentError, "No Such Sender, \'#{ sender }\'" if !@@senders.has_key? sender
            raise ArgumentError, "Event Name Not Symbol" if !event.is_a? Symbol

            event = Event.new(sender, event)

            @@events = @@events | [event] # Unique add event
            @@dispatch[ @@events.index( event ) ] ||= [] # Add a record in dispatch if it doesn't already exist

        end

        def add_registrar( registrar, *events )

            raise ArgumentError, "Registrar is not a Plugin" if !registrar.kind_of? Plugin

            @@registrars = @@registrars | [registrar] # Unique add registrar
            registrar_id = @@registrars.index( registrar ) # Precompute registrar_id once for adding to dispatch
            events.each { |event|

                if event =~ /^(.+)->(.+)$/i # Check the notification is in the format "sender->event"
                    sender = $1.to_sym	    # Get the sender and events from Regexp globals
                    event_name = $2.to_sym
                else
                    raise ArgumentError, "Event: \'#{ event }\' in incorrect format"
                end

                event_id = @@events.index( Event.new( sender, event_name ) ) # Find event id based on sender and event

                if event_id.nil?
                    raise ArgumentError, "No Such Sender (Event: \'#{event}\')"
                end

                @@dispatch[ event_id ] = @@dispatch[ event_id] | [registrar_id] # add registrar_id to appropriate dispatch record

            }

        end

        def broadcast( event_name, sender, *args )

            sender_desc = @@senders.key( sender )

            raise ArgumentError, "No Such Sender, \'#{ sender }\'" if sender_desc.nil?

            event = Event.new( sender_desc, event_name )
            event_id = @@events.index( event )

            raise ArgumentError, "No Such Event, \'#{ event_name }\'" if event_id.nil?

            method_calls = []
            @@dispatch[ event_id ].each { |registrar_id|
                # Iterate through registered registrars, send them the the method call.
                method_calls << Thread.new(event, args) { |ev, ar| @@registrars[ registrar_id ].send( ev.name, *ar ) }
            }

            method_calls.each { |call| call.join }
        end

        def remove_registrar( registrar )

            registrar_id = @@registrars.index( registrar )

            @@dispatch.each_pair { |event_id, registrar_array|

                @@dispatch[ event_id ] = registrar_array - [registrar_id]
            }

            @@registrars[ registrar_id ] = nil

        end

        def remove_event( sender, event )

            s_event  = Event.new( sender, event )
            event_id = @@events.index( s_event )

            @@dispatch.delete( event_id )
            @@events[ event_id ] = nil

        end

        def remove_sender( sender )

            sender_desc = @@senders.key( sender )

            @@events.select { |event| event.sender == sender_desc }.each { |invalid_event|
                inv_event_id = @@events.index( invalid_event )
                @@dispatch.delete( inv_event_id )
            }

            @@events.select! { |event|
                event.sender != sender_desc
            }

            @@senders.delete( sender_desc )

        end

        debug_dump_ivars

            print "Senders\n"

            @@senders.each_pair { |desc, sender|
                print "#{ desc.to_s }: #{sender.inspect}\n"
            }

            print "\nRegistrars\n"

            i = 0
            @@registrars.each { |registrar|
                print "#{ i.to_s.ljust(3) }. #{registrar.inspect}\n"
                i += 1
            }

            print "\nEvents\n"

            i = 0
            @@events.each { |event|
                print "#{ i.to_s.ljust(3) }. #{event.inspect}\n"
                i += 1
            }

            print "\nDispatch\n"

            @@dispatch.each_pair { |event_id, registrars|
                c_event = @@events[ event_id ]

                print "[#{ c_event.sender }->#{ c_event.name }]\n"

                registrars.each{ |plugin_id|
                    print "\t>>> #{ @@registrars[ plugin_id ]._name }"
                    print " ( #{ plugin_id} )\n"
                }
            }
        end

    end
end

EventManager.setup
