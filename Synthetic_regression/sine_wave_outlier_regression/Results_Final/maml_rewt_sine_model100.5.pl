��
l��F� j�P.�M�.�}q (X   protocol_versionqM�X   little_endianq�X
   type_sizesq}q(X   shortqKX   intqKX   longqKuu.�(X   moduleq clearn2learn.algorithms.maml
MAML
qXV   C:\ProgramData\Anaconda3\envs\pytorch\lib\site-packages\learn2learn\algorithms\maml.pyqX�  class MAML(BaseLearner):
    """

    [[Source]](https://github.com/learnables/learn2learn/blob/master/learn2learn/algorithms/maml.py)

    **Description**

    High-level implementation of *Model-Agnostic Meta-Learning*.

    This class wraps an arbitrary nn.Module and augments it with `clone()` and `adapt()`
    methods.

    For the first-order version of MAML (i.e. FOMAML), set the `first_order` flag to `True`
    upon initialization.

    **Arguments**

    * **model** (Module) - Module to be wrapped.
    * **lr** (float) - Fast adaptation learning rate.
    * **first_order** (bool, *optional*, default=False) - Whether to use the first-order
        approximation of MAML. (FOMAML)
    * **allow_unused** (bool, *optional*, default=None) - Whether to allow differentiation
        of unused parameters. Defaults to `allow_nograd`.
    * **allow_nograd** (bool, *optional*, default=False) - Whether to allow adaptation with
        parameters that have `requires_grad = False`.

    **References**

    1. Finn et al. 2017. "Model-Agnostic Meta-Learning for Fast Adaptation of Deep Networks."

    **Example**

    ~~~python
    linear = l2l.algorithms.MAML(nn.Linear(20, 10), lr=0.01)
    clone = linear.clone()
    error = loss(clone(X), y)
    clone.adapt(error)
    error = loss(clone(X), y)
    error.backward()
    ~~~
    """

    def __init__(self,
                 model,
                 lr,
                 first_order=False,
                 allow_unused=None,
                 allow_nograd=False):
        super(MAML, self).__init__()
        self.module = model
        self.lr = lr
        self.first_order = first_order
        self.allow_nograd = allow_nograd
        if allow_unused is None:
            allow_unused = allow_nograd
        self.allow_unused = allow_unused

    def forward(self, *args, **kwargs):
        return self.module(*args, **kwargs)

    def adapt(self,
              loss,
              first_order=None,
              allow_unused=None,
              allow_nograd=None):
        """
        **Description**

        Takes a gradient step on the loss and updates the cloned parameters in place.

        **Arguments**

        * **loss** (Tensor) - Loss to minimize upon update.
        * **first_order** (bool, *optional*, default=None) - Whether to use first- or
            second-order updates. Defaults to self.first_order.
        * **allow_unused** (bool, *optional*, default=None) - Whether to allow differentiation
            of unused parameters. Defaults to self.allow_unused.
        * **allow_nograd** (bool, *optional*, default=None) - Whether to allow adaptation with
            parameters that have `requires_grad = False`. Defaults to self.allow_nograd.

        """
        if first_order is None:
            first_order = self.first_order
        if allow_unused is None:
            allow_unused = self.allow_unused
        if allow_nograd is None:
            allow_nograd = self.allow_nograd
        second_order = not first_order

        if allow_nograd:
            # Compute relevant gradients
            diff_params = [p for p in self.module.parameters() if p.requires_grad]
            grad_params = grad(loss,
                               diff_params,
                               retain_graph=second_order,
                               create_graph=second_order,
                               allow_unused=allow_unused)
            gradients = []
            grad_counter = 0

            # Handles gradients for non-differentiable parameters
            for param in self.module.parameters():
                if param.requires_grad:
                    gradient = grad_params[grad_counter]
                    grad_counter += 1
                else:
                    gradient = None
                gradients.append(gradient)
        else:
            try:
                gradients = grad(loss,
                                 self.module.parameters(),
                                 retain_graph=second_order,
                                 create_graph=second_order,
                                 allow_unused=allow_unused)
            except RuntimeError:
                traceback.print_exc()
                print('learn2learn: Maybe try with allow_nograd=True and/or allow_unused=True ?')

        # Update the module
        self.module = maml_update(self.module, self.lr, gradients)

    def clone(self, first_order=None, allow_unused=None, allow_nograd=None):
        """
        **Description**

        Returns a `MAML`-wrapped copy of the module whose parameters and buffers
        are `torch.clone`d from the original module.

        This implies that back-propagating losses on the cloned module will
        populate the buffers of the original module.
        For more information, refer to learn2learn.clone_module().

        **Arguments**

        * **first_order** (bool, *optional*, default=None) - Whether the clone uses first-
            or second-order updates. Defaults to self.first_order.
        * **allow_unused** (bool, *optional*, default=None) - Whether to allow differentiation
        of unused parameters. Defaults to self.allow_unused.
        * **allow_nograd** (bool, *optional*, default=False) - Whether to allow adaptation with
            parameters that have `requires_grad = False`. Defaults to self.allow_nograd.

        """
        if first_order is None:
            first_order = self.first_order
        if allow_unused is None:
            allow_unused = self.allow_unused
        if allow_nograd is None:
            allow_nograd = self.allow_nograd
        return MAML(clone_module(self.module),
                    lr=self.lr,
                    first_order=first_order,
                    allow_unused=allow_unused,
                    allow_nograd=allow_nograd)
qtqQ)�q}q(X   trainingq�X   _parametersqccollections
OrderedDict
q	)Rq
X   _buffersqh	)RqX   _backward_hooksqh	)RqX   _forward_hooksqh	)RqX   _forward_pre_hooksqh	)RqX   _state_dict_hooksqh	)RqX   _load_state_dict_pre_hooksqh	)RqX   _modulesqh	)Rqh (h csine_wave_outlier_regression.maml_synthetic_reweight
SyntheticMAMLModel
qX�   C:\Users\krish\OneDrive - The University of Texas at Dallas\Documents\metaL-dss\sine_wave_outlier_regression\maml_synthetic_reweight.pyqXU  class SyntheticMAMLModel(nn.Module):
    def __init__(self):
        super(SyntheticMAMLModel, self).__init__()
        self.model = nn.Sequential(
            nn.Linear(1, 40),
            nn.ReLU(),
            nn.Linear(40, 40),
            nn.ReLU(),
            nn.Linear(40, 1))

    def forward(self, x):
        return self.model(x)
qtqQ)�q}q(h�hh	)Rqhh	)Rq hh	)Rq!hh	)Rq"hh	)Rq#hh	)Rq$hh	)Rq%hh	)Rq&X   modelq'(h ctorch.nn.modules.container
Sequential
q(XU   C:\ProgramData\Anaconda3\envs\pytorch\lib\site-packages\torch\nn\modules\container.pyq)XE
  class Sequential(Module):
    r"""A sequential container.
    Modules will be added to it in the order they are passed in the constructor.
    Alternatively, an ordered dict of modules can also be passed in.

    To make it easier to understand, here is a small example::

        # Example of using Sequential
        model = nn.Sequential(
                  nn.Conv2d(1,20,5),
                  nn.ReLU(),
                  nn.Conv2d(20,64,5),
                  nn.ReLU()
                )

        # Example of using Sequential with OrderedDict
        model = nn.Sequential(OrderedDict([
                  ('conv1', nn.Conv2d(1,20,5)),
                  ('relu1', nn.ReLU()),
                  ('conv2', nn.Conv2d(20,64,5)),
                  ('relu2', nn.ReLU())
                ]))
    """

    def __init__(self, *args):
        super(Sequential, self).__init__()
        if len(args) == 1 and isinstance(args[0], OrderedDict):
            for key, module in args[0].items():
                self.add_module(key, module)
        else:
            for idx, module in enumerate(args):
                self.add_module(str(idx), module)

    def _get_item_by_idx(self, iterator, idx):
        """Get the idx-th item of the iterator"""
        size = len(self)
        idx = operator.index(idx)
        if not -size <= idx < size:
            raise IndexError('index {} is out of range'.format(idx))
        idx %= size
        return next(islice(iterator, idx, None))

    @_copy_to_script_wrapper
    def __getitem__(self, idx):
        if isinstance(idx, slice):
            return self.__class__(OrderedDict(list(self._modules.items())[idx]))
        else:
            return self._get_item_by_idx(self._modules.values(), idx)

    def __setitem__(self, idx, module):
        key = self._get_item_by_idx(self._modules.keys(), idx)
        return setattr(self, key, module)

    def __delitem__(self, idx):
        if isinstance(idx, slice):
            for key in list(self._modules.keys())[idx]:
                delattr(self, key)
        else:
            key = self._get_item_by_idx(self._modules.keys(), idx)
            delattr(self, key)

    @_copy_to_script_wrapper
    def __len__(self):
        return len(self._modules)

    @_copy_to_script_wrapper
    def __dir__(self):
        keys = super(Sequential, self).__dir__()
        keys = [key for key in keys if not key.isdigit()]
        return keys

    @_copy_to_script_wrapper
    def __iter__(self):
        return iter(self._modules.values())

    def forward(self, input):
        for module in self:
            input = module(input)
        return input
q*tq+Q)�q,}q-(h�hh	)Rq.hh	)Rq/hh	)Rq0hh	)Rq1hh	)Rq2hh	)Rq3hh	)Rq4hh	)Rq5(X   0q6(h ctorch.nn.modules.linear
Linear
q7XR   C:\ProgramData\Anaconda3\envs\pytorch\lib\site-packages\torch\nn\modules\linear.pyq8X�	  class Linear(Module):
    r"""Applies a linear transformation to the incoming data: :math:`y = xA^T + b`

    Args:
        in_features: size of each input sample
        out_features: size of each output sample
        bias: If set to ``False``, the layer will not learn an additive bias.
            Default: ``True``

    Shape:
        - Input: :math:`(N, *, H_{in})` where :math:`*` means any number of
          additional dimensions and :math:`H_{in} = \text{in\_features}`
        - Output: :math:`(N, *, H_{out})` where all but the last dimension
          are the same shape as the input and :math:`H_{out} = \text{out\_features}`.

    Attributes:
        weight: the learnable weights of the module of shape
            :math:`(\text{out\_features}, \text{in\_features})`. The values are
            initialized from :math:`\mathcal{U}(-\sqrt{k}, \sqrt{k})`, where
            :math:`k = \frac{1}{\text{in\_features}}`
        bias:   the learnable bias of the module of shape :math:`(\text{out\_features})`.
                If :attr:`bias` is ``True``, the values are initialized from
                :math:`\mathcal{U}(-\sqrt{k}, \sqrt{k})` where
                :math:`k = \frac{1}{\text{in\_features}}`

    Examples::

        >>> m = nn.Linear(20, 30)
        >>> input = torch.randn(128, 20)
        >>> output = m(input)
        >>> print(output.size())
        torch.Size([128, 30])
    """
    __constants__ = ['in_features', 'out_features']

    def __init__(self, in_features, out_features, bias=True):
        super(Linear, self).__init__()
        self.in_features = in_features
        self.out_features = out_features
        self.weight = Parameter(torch.Tensor(out_features, in_features))
        if bias:
            self.bias = Parameter(torch.Tensor(out_features))
        else:
            self.register_parameter('bias', None)
        self.reset_parameters()

    def reset_parameters(self):
        init.kaiming_uniform_(self.weight, a=math.sqrt(5))
        if self.bias is not None:
            fan_in, _ = init._calculate_fan_in_and_fan_out(self.weight)
            bound = 1 / math.sqrt(fan_in)
            init.uniform_(self.bias, -bound, bound)

    def forward(self, input):
        return F.linear(input, self.weight, self.bias)

    def extra_repr(self):
        return 'in_features={}, out_features={}, bias={}'.format(
            self.in_features, self.out_features, self.bias is not None
        )
q9tq:Q)�q;}q<(h�hh	)Rq=(X   weightq>ctorch._utils
_rebuild_parameter
q?ctorch._utils
_rebuild_tensor_v2
q@((X   storageqActorch
FloatStorage
qBX   2170595028624qCX   cuda:0qDK(NtqEQK K(K�qFKK�qG�h	)RqHtqIRqJ�h	)RqK�qLRqMX   biasqNh?h@((hAhBX   2170595027664qOX   cuda:0qPK(NtqQQK K(�qRK�qS�h	)RqTtqURqV�h	)RqW�qXRqYuhh	)RqZhh	)Rq[hh	)Rq\hh	)Rq]hh	)Rq^hh	)Rq_hh	)Rq`X   in_featuresqaKX   out_featuresqbK(ubX   1qc(h ctorch.nn.modules.activation
ReLU
qdXV   C:\ProgramData\Anaconda3\envs\pytorch\lib\site-packages\torch\nn\modules\activation.pyqeXB  class ReLU(Module):
    r"""Applies the rectified linear unit function element-wise:

    :math:`\text{ReLU}(x) = (x)^+ = \max(0, x)`

    Args:
        inplace: can optionally do the operation in-place. Default: ``False``

    Shape:
        - Input: :math:`(N, *)` where `*` means, any number of additional
          dimensions
        - Output: :math:`(N, *)`, same shape as the input

    .. image:: scripts/activation_images/ReLU.png

    Examples::

        >>> m = nn.ReLU()
        >>> input = torch.randn(2)
        >>> output = m(input)


      An implementation of CReLU - https://arxiv.org/abs/1603.05201

        >>> m = nn.ReLU()
        >>> input = torch.randn(2).unsqueeze(0)
        >>> output = torch.cat((m(input),m(-input)))
    """
    __constants__ = ['inplace']

    def __init__(self, inplace=False):
        super(ReLU, self).__init__()
        self.inplace = inplace

    def forward(self, input):
        return F.relu(input, inplace=self.inplace)

    def extra_repr(self):
        inplace_str = 'inplace=True' if self.inplace else ''
        return inplace_str
qftqgQ)�qh}qi(h�hh	)Rqjhh	)Rqkhh	)Rqlhh	)Rqmhh	)Rqnhh	)Rqohh	)Rqphh	)RqqX   inplaceqr�ubX   2qsh7)�qt}qu(h�hh	)Rqv(h>h?h@((hAhBX   2170595028144qwX   cuda:0qxM@NtqyQK K(K(�qzK(K�q{�h	)Rq|tq}Rq~�h	)Rq�q�Rq�hNh?h@((hAhBX   2170595028720q�X   cuda:0q�K(Ntq�QK K(�q�K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�uhh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�haK(hbK(ubX   3q�hd)�q�}q�(h�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hr�ubX   4q�h7)�q�}q�(h�hh	)Rq�(h>h?h@((hAhBX   2170595027472q�X   cuda:0q�K(Ntq�QK KK(�q�K(K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�hNh?h@((hAhBX   2170595028336q�X   cuda:0q�KNtq�QK K�q�K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�uhh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�haK(hbKubuubsubsX   lrq�G?�z�G�{X   first_orderq��X   allow_nogradqX   allow_unusedqÉub.�]q (X   2170595027472qX   2170595027664qX   2170595028144qX   2170595028336qX   2170595028624qX   2170595028720qe.(       ��6��]��M_�?	��՜���=�a���">B4?=	�e?�=T���7�w�>!�?��L��)��?�)?��?��-��>/"!>��	���<x�c�}i>�%"���>ޘF�I�(?��8��ݽ=���<*	~=�"?割=] ?,`��V#��c>(       �>���=�X��N�=�?Κ��7��>]�?��$>�#/��v=f?��@�7���s���ۭ�N��>�>�?�q����>��<��h!�)�Q�yކ�*�d���-y��u>@��t���c�=�@�Jſ|(ÿ�Ϥ���=�ɳ=«`�d�>@      I�����6��5޽�9���q=e��֣��3���Bb�h���5��=Me��� ��Ϯ�-?������Ǖ��Խ �@:a~A��v�;��!�E��=���5D��l�3
(�63�=�pv=U/���=4�<7�M>{mϽ��W���8���Z=�cK�tY��R�� �ǻ}[ս8R�6�)��L��==�=�i�=:�S�Uץ��O�:���jf�Xr�<��H��D��jn=� �)��B��=R�=�n#�$�T� d�^�0��=�4�?���n�Fs��1+���=����np��s��R��-�V��OԽN�3H>=俢�b�J��=4��?�ֿ�A��H�2�t{�>&�9�k7�c��?�)��D����˿k�!�����Y�>�TF?9Ǝ����.a��>���?����p��������N��>?���뿨���J��,V�E����g�<{���+	;v!M�h�	Z5��>н��f��=S]λ5a�=�y'�`b׽2��<�;���D��=Ohͽ1���t��-���=6�=\��7�W�=֨w� ǋ=&�7��z���(�b͎=)�F��~��A[�;�	3��C�<�5�k��=�}����<g�;�!�� �(=������=���˾0���!k?J�>ōH�/�5�ӧ��/��tJ��X@?�p��� ��i���"�;�]���;^�>�ݖ�
�c��A��$e=#9Y���>@<�<{]�=G�>z��>h�ǽ犵����I�U�R=�8=�Ī�|z��{����(�����N�&�Y�+=���4X=�落�g2=�A�A���N������뙀���u�Vވ������!7�@[���J���<�@㽽:*��^7 *�;'ܽ)/�𽭽M0�=BMT�G)��8砽;�+��������&Cb;�9���m��8U�b\���׽�#��>-�ɾ�r�V�ٽ?=ݖ= $����a�@�3�d|�_q�&i5?��A����@T��6�X۝�t����>����Hr����A<�˕� D%���潠�)=��C�i��<A��>>��=��=t���üʇ�=��ǽз�������*�ӽn{|�0�Y�H���j�Z> �2=�ժ����mh<�ڼ��ܧ=S>1��w%�ež#+��t�>�叼��$>D|�< �=�s��@I��ƭ%��$�=��|�Aν{�j=�4:=���R�!�nK`�'νʊ&>��>T`���������*7����<�}쾕��h��6�^�a?rL���=�W���`��,rþ��V��>x��=�F���0|�������ľ%�=�.�y��=���#���O齎�ݽ�t�=���1������w>V�p<V�t���wY�>�U��z�}?NM�=h�>��>��� ����>��=9hn>6Т���>�-㿆gn��?��>�p� �����x>??%D���*��I?;[?(��H��� ��N��{��Ƥ|?)�C��z?I�)��(��.����
e�=�=�����>��$7⿹f��>�;���p��~�/����[*�>��#>�pm?j?��u'���K�`2��A؞?�_��چɽ_�&��?���O<����/U?,'��S�>����>.�;}���V��>_�輼rB�Sf~���L>����%����~O�0�z�[�¾d�> ��<��$�>T���<>�*�>F�=�0��fE������)��r�����ļ��g������G=���=hY��v(=�a�;��=����P(�<�	��p��C"0�(� �&�e�(�<!�E���v�O	�K"��)潽#��&�<�<=Z�O�H<�?��.:Ȼ=6&��Dξ^Q�;G?���'���E�E��Q�y�2�J=sKk� B?�0�Hk�=� �����>��^��=��>7�2=� ɽ `��J���w*��RL�����^��0�(�����=�)��s�]���(=��5��!�>D�\�ק���I>7w�sf>/��>]�@�0���Ἀ��>~CD�;XG=iq=9��j�=<�;���������0=s�ľǒ:>Xt�?)+?7� =Jω�Ø�>]<����H����k¾��N>�}��n�?&?ll�=�/��|�n�5��S�=-�>��q��4 >VZ	>�[�N�7�H�{>�?���������bپ�Ҿ��s>й�>W�~���{P��C�y��22=�����%>��2=`M���[��T��YE=l-+<�a#�`̇����n`@�Lj�Q&��i=�y���˽�b���N�
���6=��������_�ӽzP��<l���	ֽ��,=����w��i�����v�ۭ��ń��ML���3�9$2տ@����b���7���?�n�=��5��,z�H��5����6�Jo�>Ζ�����7%��7�;_7��v�?/�<�!(�A`�7��{=���\$�������ľz�=��̿󽾂/�=E�R	�=";�u|�RAĽ��y�i����
�-�K�3�S)���-�>|�߽�]�cD=o?�]&>�=�닾8g��ǭ�%����
�>:-�35=�r"�d}�?,�>L�P����ص���S��C��P�F>*t�=���<�G�9����e�<^�>�A�>U��<D.������
Ed����tZ�>iO�R���K����]Z?��ƾx�=�S����<E�ȾLGE��1C<4Ż<3舽��5����������VG?����=�iN�E�罭�=y+n����>\ս��'6= ��<h��<���d��vO��~�?��g�|Ň?oz>��>�?$�lr��ԋ=��=9�
?�n�=���>�&I���W=�-Ϳ��=Y5ڽ��={,4?�W���ؾ�X���H�>�p���Ҿ�j�>�������*)���뽖tx>֩�� l�;%ֿ��"�=�d!��*�=�>�aȽ-45��!�=��>)`q>������~����K�eU��7!�>��>=�="����O㾀n=c5f?b=Aa�4���}�����S��?X�o�Y��;)S�h��=@Q\�s�=���>t�X����=����.��=������>z�T�.Ŀ=���=�b�>8w:��Ľ��Z�伙Q��������<�依孿�
���ۆ���v=�ڼ<m�>�Q >���¹Z�1��>q(>#�1�T$=�q;�*;(�y�R5�>����K��$ĽW99?�M��=f�A/�����;����M< �hb�;�f>�'�=o�=�n=
�N=��>�Z��ǽI=�|�=�1�7���l��
;���1���/��>�~1�%}�J���*�=����~:�k�N�=4s�k!�/>��[;�V9�1�,�?n��������9ӂJ=�������8=v�*=�Y>�U�=�����1���=�ݽШ
�1�=��L�}m���=k�>�3t�c �=�`E�+W��Ȍ<H���[�=+����u�<��i@����� ��g];IA���x���}�n�����`=�<#=˴�<]Od�xW���}�0e�<��c��$=�
��}H<Z�%�E����<��"Y�s߽~�z����\��,��=>�>�ܽ�޽��<��0��'�Ž�=��;�X��0r4�u��<wUQ��3.�eD�=�u6�����*�
 �ج�=h�H�s:;t�s=�n��{ܼ��<�><��:��Ǟ�(�W��?%=�[
�}io�j^<���L����yu��+J<��SWe<��������!����?�몾/W �=��j����=���>G��?�3�����5=��b�ލe�#>i��=��>z�z���m?�=H����>UP�@��뽱���Sr
�+���R��̜���X���5�)t�>��L>��-��Dģ�O�ža}?���>TV�?w˽ݥ4��Ar>��=���;(>�"�?��_?�%:�-�ؽ�λ�䁾�-��<b�>��M�V��=�C�<?z�>��ꚾ�@Ⱦ锝�(sѼJ�W���L�0+c=3�½��=��v������>�c>=��&ټ����dm+�s❽K�F����<Ҳ��{�c���=~h�=IC�.���֫�=���C��h+Ƚ����ʑ���r�c����>�ý�v;�V'=�&��G�=���`�O<��>��p�*=�T�=�Z˽jEg=d��8i�GI���ԻJ�����;0��弩��������m)=H.�<��J>�k��A�>�0>u?Y
����>�!�=������>%�>���>��&���r>	�g����=�JP?�����i>۾OK�>���=W�X>�~o�Ў�<4�c�1�����S���M�P+۽b�˿t�_�*K�>��a>�
�>:�!>R������a���?%����ɼ�=�ھ�=t+-?D��>"<^<q䯽�I?�Ơ�登��B��g��8�B�%���2�?Cv�����>�꓾�ڤ��/�b�?���>���<�I|>�h�E(Q?KpA>|!���?��t>W>,�m�Jk�>���?�V�>���<�2��! ��G�3?Nlu�a�
��G�;� (�K!����!k?��׾�2�~=�>R?耿ζ��a�e���ؽѯP��O?�\����>d���Ƚ���A�4H|�P��;#<זȽ��J�e�E���N�f>�=_N&�Z Կ&�������b�M>��>�iw?!���O� ���F\����<�E�����<�W��>�=L��a������m���*��(�A=9,��,-��Q���<�~�}��=*ҳ�(E�<XI�;�g�=<�=��=���n�� �����=9�����Q=�|��X}=�t=t��3a̽I)��$�X�<r��;<��nؽG�%�!O������?}�=G�;�x��Ԉ���|_=P��RQB��1��_�<��;+���U�=�Ύ�)�#�Hi�<���#s�=x�"=�4����mJýh��='�'��N����=C3��w�ѽ.xy=��=�|����=�:�;��Ӿ�q�>�����3���{�>G@�z�/�'�=�9=�=B�^@���#�ăҽ�>�n��;WbN=���<a\�ʆ8�K��rp)�@>���=1�^<w�i�$>ýr��s����䧾s)�=��ڽ��=?�)M=	�"��>����qv�5��=����*)>9K�=]�J��6�����=#�����>=ն��l�=�ϋ=�����q=���|�,=����Ȳ��V��sU>@Jf�|��= �1:m2�.�\���=s=��ڼ���=|
�J�E�Z���(���-��¢�CB�8	9=0-�<B��=��½�n�����<�v�1c(?�^�=Fw1?T"A=�K��%�=\(�U$��	�?l����z�v����C�3Z?u1˾��*>�3/�2�>j�?�yL�����`⾀o&���Z�ԛ#>�C�����=�ϼn�o>$
��3��>�ݗ>-��=�I�ξ+����!?�2zP?\��~0o?b���m�j���O=�[�;cP���O=g�������4�߽�#�����xe�;,�;�����j<3�+�ۣ��m�=�|��l��� �k�y��s8=�+�<
~(���9<D��:�<b��<=���<d���$!1�T6*��(o��¿=�ۘ�8���iV���߽�m>����Ծ�>b���������nn�>�R$>�A��	���M/>Bj���2�Qy�>�s?��.��8
��Ә?)��>FG���3��+�u=�. >E\�:�=2I�=屮���<x'u=E9�(��>��k>̰�S�N���	p:���2>?_C��2~��վ��h�SH�z����=o��gF�0�C��'`�Z�"��&D�/T<��ӽ��-���I=��=h���WD��!�=���~�����=_N2��_Ƽ}-��R�!�>���<�d�{����g�	�'>�쀼�@���%���1!�c��=b݁�߇=�~L�1��=s�v=�3������_o=��!�qw?X�\=\�`=\��=��r�ˡ#<_jD�o7?��)<vJ�k�����/��=�l��$9�>FJ���j��8�=��=m�+�\U��La=ຓ� M�=����Z}2��TH=	H�$��Lm�Yl�<\�q��)����E���@�4<��Q���T$���=�A�Z���`�u<�!�>n�%>������=|&���q��K����2�HAL�t3S��� ��O>�Ys=��p�j¿�C�=�Y >�R�U��;C�>ۥ%>�Y>���z|��e�5>���>I�=�/r�\/S=�¾��>�Gӽ6n�;�       \h��(       M�C<�=��?��X=g½�t?-
�;v�ڽ�"ǽ���O�]���K�>�N??%��h�>�I�Z�-=����։� �(>�3���G�_CD��j?@˽P��>��>�D=�wS�=?GMϼ1��>����섿�뷾��e��{r2>���(       h9{=n��=���>8��<��i�X����V�����׮>�$s��$������59���꽻�A>�u������Wt��VG��B7�?L���A���o?ì\�6�<,��=і�>���>�A?��uܽP�>����a��/⍽��E��~��'� � �