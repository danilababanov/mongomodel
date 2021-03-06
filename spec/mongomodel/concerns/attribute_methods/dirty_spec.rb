require 'spec_helper'

module MongoModel
  specs_for(Document, EmbeddedDocument) do
    if specing?(Document)
      define_class(:TestDocument, Document) do
        property :foo, String
        property :bar, String
      end

      subject { TestDocument.create!(:foo => 'original foo') }
    else
      define_class(:ChildDocument, EmbeddedDocument) do
        property :foo, String
        property :bar, String
      end

      define_class(:ParentDocument, Document) do
        property :child, ChildDocument
      end

      let(:child) { ChildDocument.new(:foo => 'original foo') }
      let(:parent) { ParentDocument.create!(:child => child) }

      subject { parent.child }
    end

    def reset_subject!
      subject.respond_to?(:restore_foo!) ? subject.restore_foo! : subject.reset_foo!
    end

    describe "#write_attribute" do
      before(:each) do
        subject.write_attribute(:foo, 'new foo')
      end

      it "adds the old attribute name to the changed attributes" do
        subject.changed.should include("foo")
      end

      it "does not add other attributes to the changed attributes" do
        subject.changed.should_not include("bar")
      end

      it "adds the changed attribute value to the changes hash" do
        subject.changes["foo"].should == ['original foo', 'new foo']
      end

      context "when called twice" do
        before(:each) do
          subject.write_attribute(:foo, 'new foo #2')
        end

        it "keeps the original value as the old value in the changes hash" do
          subject.changes["foo"].should == ['original foo', 'new foo #2']
        end
      end
    end

    context "with changed attributes" do
      context "attribute set to a new value" do
        before(:each) do
          subject.foo = 'foo changed'
        end

        it { should be_changed }

        it "has a changed attribute" do
          subject.foo_changed?.should == true
        end

        it "tells what the attribute was" do
          subject.foo_was.should == "original foo"
        end

        it "has an attribute change" do
          subject.foo_change.should == ["original foo", "foo changed"]
        end

        it "is able to reset/restore an attribute" do
          reset_subject!
          subject.foo.should == "original foo"
          subject.changed?.should == false
        end
      end

      context "attribute set to the original value" do
        before(:each) do
          subject.foo = 'original foo'
        end

        it { should_not be_changed }

        it "does not have a changed attribute" do
          subject.foo_changed?.should == false
        end

        it "tells what the attribute was" do
          subject.foo_was.should == "original foo"
        end

        it "does not have an attribute change" do
          subject.foo_change.should == nil
        end

        it "is able to reset/restore an attribute" do
          reset_subject!
          subject.foo.should == "original foo"
          subject.changed?.should == false
        end
      end
    end

    context "without changed attributes" do
      it { should_not be_changed }

      it "does not have a changed attribute" do
        subject.foo_changed?.should == false
      end

      it "tells what the attribute was" do
        subject.foo_was.should == "original foo"
      end

      it "does not have an attribute change" do
        subject.foo_change.should == nil
      end

      it "is able to reset/restore an attribute" do
        reset_subject!
        subject.foo.should == "original foo"
        subject.changed?.should == false
      end
    end

    context "#original_attributes" do
      context "with changes" do
        before(:each) do
          subject.foo = 'changed foo'
        end

        it "returns the attributes before changes" do
          subject.original_attributes['foo'].should == 'original foo'
        end
      end

      context "without changes" do
        it "returns the attributes hash" do
          subject.original_attributes.symbolize_keys.should == subject.attributes
        end
      end
    end
  end

  specs_for(Document) do
    define_class(:TestDocument, Document) do
      property :foo, String
    end

    subject { TestDocument.create!(:foo => 'original foo') }

    context "when saved" do
      before(:each) do
        subject.foo = 'changed foo'
      end

      context "with save" do
        it "resets the changed attributes" do
          subject.save
          subject.should_not be_changed
        end
      end

      context "with save!" do
        it "resets the changed attributes" do
          subject.save!
          subject.should_not be_changed
        end
      end
    end

    context "when instantiated from database" do
      it "is not changed" do
        instance = TestDocument.find(subject.id)
        instance.should_not be_changed
      end
    end
  end
end
