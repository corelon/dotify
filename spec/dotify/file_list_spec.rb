require 'spec_helper'
require 'dotify/config'
require 'dotify/file_list'

describe Dotify::List do

  describe Dotify::List, "#home" do
    before do
      Dotify::Config.stub(:home).and_return("/home/test")
    end
    it "should call List#list with the correct path" do
      Dotify::List.should_receive(:paths) \
        .with("/home/test/.*").once \
        .and_return(['/root/test/.vimrc', '/root/test/.bashrc', '/root/test/.zshrc'])
      Dotify::List.home
    end
    it "should drop files that have been specified to be ignored" do
      Dotify::List.stub(:paths) do
        ['/root/test/.gitconfig', '/root/test/.vimrc', '/root/test/.bashrc', '/root/test/.zshrc']
      end
      Dotify::Config.stub(:ignore).with(:dotfiles).and_return %w[.zshrc .vimrc]
      result = Dotify::List.home
      result.should include '/root/test/.bashrc'
      result.should include '/root/test/.gitconfig'
      result.should_not include '/root/test/.zshrc'
      result.should_not include '/root/test/.vimrc'
    end
  end

  describe Dotify::List, "#dotify" do
    it "should call List#list with the correct path" do
      Dotify::Config.stub(:path).and_return("/home/test/.dotify")
      Dotify::List.should_receive(:paths) \
        .with("/home/test/.dotify/.*").once \
        .and_return(['/spec/test/.vimrc', '/spec/test/.bashrc', '/spec/test/.zshrc'])
      Dotify::List.dotify
    end
    it "should drop files that have been specified to be ignored" do
      Dotify::List.stub(:paths) do
        ['/dotify/test/.gitconfig', '/dotify/test/.vimrc', '/dotify/test/.bashrc', '/dotify/test/.zshrc']
      end
      Dotify::Config.stub(:ignore).with(:dotify).and_return %w[.gitconfig .bashrc]
      result = Dotify::List.dotify
      result.should include '/dotify/test/.vimrc'
      result.should include '/dotify/test/.zshrc'
      result.should_not include '/dotify/test/.bashrc'
      result.should_not include '/dotify/test/.gitconfig'
    end
  end

  describe Dotify::List, "#list" do
    let(:glob) { '/spec/test/.*' }
    it "should pull the glob of dotfiles from a directory" do
      Dir.should_receive(:[]).with(glob).and_return(%w[. .. /spec/test/.vimrc /spec/test/.bashrc /spec/test/.zshrc])
      Dotify::List.list(glob)
    end
    describe "return values" do
      before do
        Dir.stub(:[]).with(glob).and_return(%w[. .. /spec/test/.vimrc /spec/test/.bashrc /spec/test/.zshrc])
      end
      let(:files) { Dotify::List.list(glob) }
      it "should return the right filenames" do
        files.should include '.vimrc'
        files.should include '.bashrc'
        files.should include '.zshrc'
      end
      it "should filter out . and .. directories" do
        files.should_not include '.'
        files.should_not include '..'
      end
    end
  end

  describe Dotify::List, "#paths" do
    let(:glob) { '/spec/test/.*' }
    it "should pull the glob of dotfiles from a directory" do
      Dir.should_receive(:[]).with(glob).and_return(%w[. .. /spec/test/.vimrc /spec/test/.bashrc /spec/test/.zshrc])
      Dotify::List.paths(glob)
    end
    describe "return values" do
      before do
        Dir.stub(:[]).with(glob).and_return(%w[. .. /spec/test/.vimrc /spec/test/.bashrc /spec/test/.zshrc])
      end
      let(:files) { Dotify::List.paths(glob) }
      it "should return the right directories" do
        files.should include '/spec/test/.vimrc'
        files.should include '/spec/test/.bashrc'
        files.should include '/spec/test/.zshrc'
      end
      it "should filter out . and .. directories" do
        files = Dotify::List.paths(glob)
        files.should_not include '.'
        files.should_not include '..'
      end
    end
  end

  describe Dotify::List, "#filenames" do
    let(:files) { %w[/spec/test/.vimrc /spec/test/.bashrc /spec/test/.zshrc] }
    it "should use Files#filename to change the files" do
      Dotify::Files.should_receive(:filename).exactly(files.count).times
      Dotify::List.filenames(files)
    end
    it "return only" do
      result = Dotify::List.filenames(files)
      result.should include '.vimrc'
      result.should include '.bashrc'
      result.should include '.zshrc'
    end
  end


end
