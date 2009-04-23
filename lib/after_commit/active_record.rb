module AfterCommit
  module ActiveRecord
    # Based on the code found in Thinking Sphinx:
    # http://ts.freelancing-gods.com/ which was based on code written by Eli Miller:
    # http://elimiller.blogspot.com/2007/06/proper-cache-expiry-with-aftercommit.html
    # with slight modification from Joost Hietbrink. And now me! Whew.
    def self.included(base)
      base.class_eval do
        # The define_callbacks method was added post Rails 2.0.2 - if it
        # doesn't exist, we define the callback manually
        if respond_to?(:define_callbacks)
          define_callbacks  :after_commit,
                            :after_commit_on_create,
                            :after_commit_on_update,
                            :after_commit_on_destroy,
                            :after_rollback,
                            :before_commit,
                            :before_commit_on_create,
                            :before_commit_on_update,
                            :before_commit_on_destroy,
                            :before_rollback
        else
          class << self
            # Handle after_commit callbacks - call all the registered callbacks.
            def after_commit(*callbacks, &block)
              callbacks << block if block_given?
              write_inheritable_array(:after_commit, callbacks)
            end
            
            def after_commit_on_create(*callbacks, &block)
              callbacks << block if block_given?
              write_inheritable_array(:after_commit_on_create, callbacks)
            end
            
            def after_commit_on_update(*callbacks, &block)
              callbacks << block if block_given?
              write_inheritable_array(:after_commit_on_update, callbacks)
            end
            
            def after_commit_on_destroy(*callbacks, &block)
              callbacks << block if block_given?
              write_inheritable_array(:after_commit_on_destroy, callbacks)
            end

            def after_rollback(*callbacks, &block)
              callbacks << block if block_given?
              write_inheritable_array(:after_commit, callbacks)
            end

            def before_commit(*callbacks, &block)
              callbacks << block if block_given?
              write_inheritable_array(:before_commit, callbacks)
            end
            
            def before_commit_on_create(*callbacks, &block)
              callbacks << block if block_given?
              write_inheritable_array(:before_commit_on_create, callbacks)
            end
            
            def before_commit_on_update(*callbacks, &block)
              callbacks << block if block_given?
              write_inheritable_array(:before_commit_on_update, callbacks)
            end
            
            def before_commit_on_destroy(*callbacks, &block)
              callbacks << block if block_given?
              write_inheritable_array(:before_commit_on_destroy, callbacks)
            end

            def before_rollback(*callbacks, &block)
              callbacks << block if block_given?
              write_inheritable_array(:before_commit, callbacks)
            end
          end
        end

        after_save    :add_committed_record
        after_create  :add_committed_record_on_create
        after_update  :add_committed_record_on_update
        after_destroy :add_committed_record_on_destroy

        # We need to keep track of records that have been saved or destroyed
        # within this transaction.
        def add_committed_record
          AfterCommit.committed_records << self
        end
        
        def add_committed_record_on_create
          AfterCommit.committed_records_on_create << self
        end
        
        def add_committed_record_on_update
          AfterCommit.committed_records_on_update << self
        end
        
        def add_committed_record_on_destroy
          AfterCommit.committed_records << self
          AfterCommit.committed_records_on_destroy << self
        end
      end
    end
  end
end
