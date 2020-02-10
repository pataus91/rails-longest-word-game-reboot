require "open-uri"

class GamesController < ApplicationController
  VOWELS = %w(A E I O U Y)

  def new
    @letters = Array.new(5) { VOWELS.sample }
    @letters += Array.new(5) { (('A'..'Z').to_a - VOWELS).sample }
    @letters.shuffle!
  end

  def score
    session[:score] = 0 if session[:score].nil?
    @letters = params[:letters].split
    @word = (params[:word] || "").upcase
    @included = included?(@word, @letters)
    @english_word = english_word?(@word)
    @score = calculate_score
    session[:score] += @score
    @total_score = session[:score]
  end

  def reset
    reset_session
    redirect_to new_url
    session[:score] = 0
  end

  private

  def calculate_score
    if @included && @english_word
      @word.length
    else
      0
    end
  end

  def included?(word, letters)
    word.chars.all? { |letter| word.count(letter) <= letters.count(letter) }
    # .chars return un'array di letter = .split("")
    # .count(letter) returns the num of times a letter appears
    # .all? { |obj| block } => Passes each element of the collection to the given block. The method returns true
    # if the block never returns false or nil. In questo caso verifica che ogni lettera dell'attempt appare
    # lo stesso num di volte o meno che nella griglia
  end

  def english_word?(word)
    response = open("https://wagon-dictionary.herokuapp.com/#{word}")
    json = JSON.parse(response.read)
    json['found']
  end
end
