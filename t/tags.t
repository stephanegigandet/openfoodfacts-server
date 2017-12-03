#!/usr/bin/perl -w

use Modern::Perl '2012';

use Test::More;

use ProductOpener::Display qw/:all/;
use ProductOpener::Tags qw/:all/;

# verify get_taxonomyid works as expected
is( get_taxonomyid('en:abc'), 'en:abc', 'lc tag with lc lang is unchanged' );
is( get_taxonomyid('abc'), 'abc', 'lc tag without is unchanged' );
is( get_taxonomyid('EN:abc'), 'en:abc', 'lc tag with uc lang is lcd' );
is( get_taxonomyid('EN:aBc'), 'en:abc', 'uc tag with uc lang is lcd' );

my $product_ref = {
	test_tags => [ 'en:test' ],
	categories => 'Meals, Gratins, Vegetable gratins, fr:Gratins de pomme de terre'
};

# verify has_tag works correctly
ok( has_tag($product_ref, 'test', 'en:test'), 'has_tag should be true' );
ok( !has_tag($product_ref, 'test', 'de:mein-tag'), 'has_tag should be false' );

# verify add_tag adds the new tag correctly
add_tag($product_ref, 'test', 'de:mein-tag');
ok( has_tag($product_ref, 'test', 'de:mein-tag'), 'has_tag should be true after add' );

# verify remove_tag removes the new tag correctly
remove_tag($product_ref, 'test', 'de:mein-tag');
ok( !has_tag($product_ref, 'test', 'de:mein-tag'), 'has_tag should be false after remove' );

# verify add_tag creates a new tags array if the matching tags field does not exist yet
add_tag($product_ref, 'nexist', 'en:test');
ok( has_tag($product_ref, 'nexist', 'en:test'), 'has_tag should be true after add' );

# verify compute_fields_tags etc. do not switch up languages of unknown taxonomized tags, see GitHub Issue openfoodfacts/openfoodfacts-server#499
$ProductOpener::Display::lc = 'de';

compute_field_tags($product_ref, 'categories');
my @expectedCategories = qw(en:meals en:gratins en:vegetable-gratins fr:gratins-de-pomme-de-terre);
is_deeply( $product_ref->{'categories_tags'}, \@expectedCategories, 'languages are correct' );

my @got = gen_tags_hierarchy_taxonomy('ru', 'categories', $product_ref->{'categories'});
is_deeply( \@got, \@expectedCategories, 'gen_tags_hierarchy_taxonomy worked correctly');

done_testing();
